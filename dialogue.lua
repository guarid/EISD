dark = require("dark")

local db = dofile("dataBase.txt")

local tags = {
	["#nomPays"] = "yellow",
	["#focus"] = "yellow",
	["#autreNoms"] = "red",
	["#coupEtat"] = "green",
	["#capitale"] = "white",
	["#langue"] = "magenta",
	["#monnaie"] = "magenta",
	["#personne"] = "magenta",
	["#revolution"] = "magenta",
	["#date"] = "blue",
	["#number"] = "blue",
	["#population"] = "white",
	["#continent"] = "red",
	["#pays"] = "red",
	["#superficie"] = "blue",
	["#organisation"] = "white",
	["#paysFrontaliers"] = "white"
}

local pipe = dark.pipeline()
pipe:basic()

pipe:model("../model-2.3.0/postag-fr")
pipe:lexicon("#nomPays", "lex/nomPays.txt")
pipe:lexicon("#prenom", "lex/prenoms.txt")
pipe:lexicon("#personne", "lex/personnages.txt")
pipe:lexicon("#continentName", {"Afrique", "Amerique", "Asie", "Europe", "Oceanie"})
pipe:lexicon("#mois", {"janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"})
pipe:lexicon("#pointsCardinaux", {"nord", "sud", "ouest", "est"})
pipe:lexicon("#ocean", {"océan Pacifique", "océan Atlantique", "océan Indien", "océan Arctique"})
pipe:lexicon("#capitale", {"capitale"})
pipe:lexicon("#paysFrontaliers", {"pays frontaliers", "pays limitrophes"})
pipe:lexicon("#monnaie", {"monnaie"})
pipe:lexicon("#langue", {"langue"})
pipe:lexicon("#guerre", {"guerre", "guerres","Guerre", "Guerres"})
pipe:lexicon("#population", {"population", "peuplée", "nombre d'habitants"})
pipe:lexicon("#continent", {"continent"})
pipe:lexicon("#superficie", {"superficie"})
pipe:lexicon("#organisation", {"organisation", "organisations"})
pipe:lexicon("#peuple", {"peuple", "peuples"})
pipe:lexicon("#revolution", {"révolution", "révolutions", "revolution", "revolutions"})
pipe:lexicon("#independance", {"indépendance", "independance", "l'indépendance", "d'indépendance"})
pipe:lexicon("#colonisateur", {"colonisé", "colonisés", "colonises", "colonise", "colonisateur"})
pipe:lexicon("#autreNoms", {"l'autre nom", "autres noms", "Autres noms", "autre nom", "Autre nom"})
pipe:lexicon("#pays", {"le pays", "les pays"})
pipe:lexicon("#min", {"la plus petite", "le plus petit", "la moins grande", "le moins grand"})
pipe:lexicon("#max", {"la moins petite", "le moins petit", "la plus grande", "le plus grand"})


pipe:lexicon("#pronomInterrogatifPersonne", {"Qui","qui"})
pipe:lexicon("#pronomInterrogatifBinaire", {"est ce que", "Est ce que", "est-ce-que", "Est-ce-que"})
pipe:lexicon("#pronomInterrogatifBinaire2", {"est ce qu'il y a", "Est ce qu'il y a", "est-ce-qu'il y a", "Est-ce-qu'il y a"})
pipe:lexicon("#pronomInterrogatifDate", {"Quand", "quand"})
pipe:lexicon("#pronomInterrogatifLieu", {"Où", "où", "Ou", "ou"})
pipe:lexicon("#pronomInterrogatifGeneralSing", {"Quel", "quel", "Quelle", "quelle"})
pipe:lexicon("#pronomInterrogatifGeneralPlu", {"Quels", "quels", "Quelles", "quelles" })
pipe:lexicon("#pronomInterrogatifChoix", {"Lequel", "Laquelle", "lequel", "laquelle"})
pipe:lexicon("#pronomInterrogatifHistoire", {"Qu'est ce qui", "Qu'est-ce-qui","qu'est ce qui", "qu'est-ce-qui"})
pipe:lexicon("#champsDetecter",{"guerre","superficie","revolution","autreNoms","l'autreNoms","capitale","indépendance","l'indépendance","evenement","l'evenement","population","langue","colonisateur","paysFrontaliers","personnage"})



pipe:pattern([[
  [#questionBinaire
    #pronomInterrogatifBinaire (/./)* ("est" | "sont") [#info (/./)*]
  ]
]])


pipe:pattern([[
  [#questionBinaire2
    #pronomInterrogatifBinaire2 (/./)* [#periode ("en" [#annee1 #d] | "entre" [#annee2 #d] "et" [#annee3 #d] | "après" [#annee4 #d] | "avant" [#annee5 #d])]
  ]
]])

-- Pattern pour détecter les guerres ayant eu lieu
pipe:pattern([[
	[#Guerre
    	("la" | "La" | (/^%u/))
    	(/^%u/)*
    	("et")*
    	(/^%u/)*
    	("Guerre" | "guerre")
    	("civile")?
    	( ((("d") ("'") (/./)) | ((/./) ("-") (/./))) | ((("de") | ("du") | ("des") | ("en")) (/^%u/)+) | ((#POS=ADJ) | (#POS=VRB) | ("civile"))  )

    ]
]])


pipe:pattern([[
	[#questionEvenement
    (#pronomInterrogatifGeneralSing | #pronomInterrogatifGeneralPlu | #pronomInterrogatifHistoire)
    (/./)* [#periode ("en" [#annee1 #d] | "entre" [#annee2 #d] "et" [#annee3 #d] | "après" [#annee4 #d] | "avant" [#annee5 #d])]
	]
]])


pipe:pattern([[
	[#questionComparaison
		#pronomInterrogatifChoix (/./)*
	]
]])

-- Pattern pour détecter une date
pipe:pattern([[
	[#date
		[#jour  #d ] ?
		(
			"/" [#mois  #d ] "/"
			|
			#mois
		)
		[#annee #d ]
	]
]])



-- Fonction pour récuperer un nombre d'une chaine de caractères
function getNumber(chaine)
  value = chaine:gsub(" ", "")
	value = value:gsub("km", "")
	value = value:gsub("de", "")

  return tonumber(value)
end


-- Fonction pour récuperer une année
function getYear(chaine)
		chaine = chaine:reverse()
		chaine = chaine:sub(0, 5)
		chaine = chaine:reverse()
		chaine = chaine:gsub(" ", "")

  return tonumber(chaine)
end

-- Fonction pour récupérer le déterminant d'un pays
function getDeterminant(nomPays)
  for k,v in pairs(db) do
    if(k == nomPays) then
      if v["determinant"] ~= nil then
        return v["determinant"]
      else
        return 0
      end
    end
  end
end

--Fonction pour récupérer les informations
function getFromCountry(nomPays, ...)
  b=0
  local arg = {...}
  for k,v in pairs(db) do
    if(k == nomPays) then
      b=1
      tab = v
      --parcours en profondeur
      for i,champ in ipairs(arg) do
        tab = tab[champ]
      end
      --On a detecte des elements
      if(tab ~= nil) then
	      return tab
	    else
	  	  return 0 --"Désolé, je n'ai pas cette information"
	    end
    end
  end

  if b==0 then
  	return -1 --"Désolé, je ne comprends pas de quel pays vous parlez"
  end

end



function getCountryName(champ, infoName)
  result = {}

  for k,v in pairs(db) do

    if type(v[champ]) == "table" then
      for i,elem in ipairs(v[champ]) do
        if (elem == infoName) then
          table.insert(result, k)
        end
	    end
	  else
      if (v[champ] == infoName) then
        table.insert(result, k)
      end
    end

  end

  return result
end

function getCountryFromTable(colonne, instance)
	result = {}
	if instance == nil then
		print("Désolé, cette guerre est inconnue")
		return nil
	end

	for k,v in pairs(db) do
		if(v[colonne] ~= nil) then
			for n,guerre in pairs(v[colonne]) do
				if string.lower(guerre) == string.lower(instance) then
					--print(k)
					table.insert(result, k)
				end
			end
		end
  end

  	return result
end

function getChampParPay(pay, champ)
  result = {}
  for k,v in pairs(db) do
      if k==pay then
        for n,c in pairs(v) do
          if n==champ and type(c)=="string" then
            table.insert(result,string.lower(c))
          elseif n==champ and type(c)=="table" then
            for m,p in pairs(c) do
              table.insert(result,string.lower(p))
            end
          end
        end
      end
  end

  return result
end


function getFromComparison(tableau, champs, compare)
  result = {}
  pays = {}
  local key, val
  for k,v in pairs(db) do
    for i,value in ipairs(tableau) do
      if(k == value) and (v[champs] ~= nil) then
        table.insert(result, v[champs])
        table.insert(pays, k)
      end
    end
  end

  for i, v in ipairs(result) do
     print(result[i], pays[i])
  end

  if #result == 0 then
    return 0
  end

  if compare == "max" then
    key, val = 1, result[1]
    val = getNumber(val)
    for k, v in ipairs(result) do
      v = getNumber(v)
      if v > val then
        key, val = k, v
        print(key, val)
      end
    end
  elseif compare == "min" then
    key, val = 1, result[1]
    val = getNumber(val)
    for k, v in ipairs(result) do
      v = getNumber(v)
      if v < val then
        key, val = k, v
      end
    end
  end

  return pays[key]

end




--Fonction pour récupérer les évènements
function getEvents(nomPays, ...)

  local arg = {...}
  local allEvents
  local result = {}
  for k,v in pairs(db) do
    if(k == nomPays) then
      if v["evenement"][1] ~= nil then
        allEvents = v["evenement"]
      else
        return -1
      end
    end
  end

  if #arg == 2 then
    limite = tonumber(arg[1])

    if arg[2] == "avant" then
      for i,v in ipairs(allEvents) do
      comp = getYear(v[1])
        if comp < limite then
          table.insert(result, v)
        end
      end

    elseif arg[2] == "après" then
      for i,v in ipairs(allEvents) do
      comp = getYear(v[1])
        if comp >= limite then
          table.insert(result, v)
        end
      end

    else
      for i,v in ipairs(allEvents) do
      comp = getYear(v[1])
        if limite == comp then
          table.insert(result, v)
        end
      end
    end

  else
    debut = tonumber(arg[1])
    fin = tonumber(arg[2])

    for i,v in ipairs(allEvents) do
      comp = getYear(v[1])
      if debut <= comp and fin > comp then
        table.insert(result, v)
        --print(v[1], v[2])
      end
    end
  end

  return result

end




-- Fonction pour récupérer la question de l'utilisateur
function getInput()
	print("EISD - Histoire pour tous\n")
  historique = {}
	while true do
		print("Bonjour! Que voulez vous savoir? (ou appuyer q pour quitter)\n")

		question = io.read()
		if question == "q" or question == "Q"  then
			break;
		end
		question = dark.sequence(question)
		pipe(question)
		local ligne
		local colonne
		if #question["#question"] ~= 0 and #question["#questionEvenement"] == 0 then

      if #question["#nomPays"] ~= 0 then

        table.insert(historique, question:tag2str("#nomPays")[1])

			  if #question["#capitale"] ~= 0 then
				    ligne = question:tag2str("#nomPays")[1]
					  colonne = "capitale"
					  local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

					  if res == 0 then
              print("Désolé, je n'ai pas cette information")
					  elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a comme capitales : ")
	            for i,elem in ipairs(res) do
	      	      print(elem)
	            end
	          else
              print(det,ligne, "a pour capitale",res)
					  end
			  end

			  if #question["#continent"] ~= 0 then
				  	ligne = question:tag2str("#nomPays")[1]
					  colonne = "continent"
					  local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

  					if res == 0 then
              print("Désolé, je n'ai pas cette information")
		  			elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "est sur plusieurs contients à savoir : ")
	            for i,elem in ipairs(res) do
	      	      print(elem)
  	          end
	          else
              print(det,ligne, "appartient au continent",res)
			  		end
			  end

  			if #question["#guerre"] ~= 0 then
	  			ligne = question:tag2str("#nomPays")[1]
		  		colonne = "guerre"
			  	local res = getFromCountry(ligne, colonne)
					local det = getDeterminant(ligne)

	  			if res == 0 then
          	print("Désolé, je n'ai pas cette information")
			  	elseif res == -1 then
          	print("Désolé, je ne comprends pas de quel pays vous parlez")
          elseif type(res) == "table" then
          	print(det,ligne, "a connu plusieurs guerres. Voici la liste :")
	        	for i,elem in ipairs(res) do
	         		print(elem)
	        	end
	        else
          	print(det,ligne, "a connu une seule guerre qui est:", res)
					end
			  end

  			if #question["#superficie"] ~= 0 then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "superficie"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs superficies qui sont :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              if det == "Le" then
                print("La superficie du", ligne,"est de:",res)
              else
                print("La superficie de",det,ligne,"est de:",res)
              end
					  end
			  end

			  if #question["#population"] ~= 0 then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "population"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs nombre d'habitants. Etonnant! Mais voici la liste :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
	            if det == "Le" then
                print("Le nombre d'habitants du", ligne,"est de:",res)
              else
                print("Le nombre d'habitants de",det,ligne,"est de:",res)
              end
					  end
			  end

  			if #question["#monnaie"] ~= 0 then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "monnaie"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "utilise plusieurs monnaies qui sont :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              print(det,ligne, "a comme monnaie :", res)
					  end
  			end

	  		if #question["#langue"] ~= 0 then
		  			ligne = question:tag2str("#nomPays")[1]
			  		colonne = "langue"
				  	local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs langues officielles qui sont :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              print(det,ligne, "a comme langue officielle :", res)
					  end
  			end

  			if #question["#paysFrontaliers"] ~= 0 then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "paysFrontaliers"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              if(det == "Le") then
                print("Les pays frontaliers du",ligne, "sont :")
  	            for i,elem in ipairs(res) do
  	              local dt = getDeterminant(elem)
	        	      print(dt,elem)
	              end
              else
                print("Les pays frontaliers de",det,ligne, "sont :")
  	            for i,elem in ipairs(res) do
	        	      print(elem)
	              end
              end
	          else
              print(det,ligne, "a un seul pays frontalier :", res)
					  end
			  end

  			if #question["#autreNoms"] ~= 0 then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "autreNoms"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              if det == "Le" then
                print("Les autres noms du",ligne, "sont :")
	              for i,elem in ipairs(res) do
	      	        print(elem)
	              end
              else
                print("Les autres noms de",det,ligne, "sont :")
	              for i,elem in ipairs(res) do
	      	        print(elem)
	              end
              end
	          else
              print(det,ligne, "a comme autre nom:", res)
					  end
			  end

  			if #question["#colonisateur"] ~= 0 then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "colonisateur"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              if det == "Le" then
               print("Les colonisateurs du",ligne, "sont :")
	              for i,elem in ipairs(res) do
  	        	    print(elem)
	              end
              else
                print("Les colonisateurs de",det,ligne, "sont :")
	              for i,elem in ipairs(res) do
    	      	    print(elem)
  	            end
              end
	          else
              print(det,ligne, "a été colonisé par :", res)
				  	end
			  end

  			if #question["#revolution"] ~= 0 then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "revolution"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a connu plusieurs révolutions à savoir:")
	            for i,elem in ipairs(res) do
	      	      print(elem)
  	          end
	          else
              print(det,ligne, "a connu une révolution à savoir :", res)
			  		end
			  end

  			if #question["#independance"] ~= 0 then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "independance"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	    			if res == 0 then
              print("Désolé, je n'ai pas cette information")
					  elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a connu plusieurs dates d'indépendance à savoir :")
  	          for i,elem in ipairs(res) do
	        	    for j,elm in ipairs(elem) do
	          	    print(elm)
  	            end
	            end
	          else
              print(det,ligne, "a eu son indépendance le :", res)
					  end
			  end





      elseif #question["#pays"] ~= 0 then

	  	  if #question["#capitale"] ~= 0 then
	  	    valeur = question:tag2str("#question", "#infoName")[1]
			    colonne = "capitale"
  			  local res = getCountryName(colonne, valeur)

	  		  if #res == 0 then
            	print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
	  	  	else
	  	  	  table.insert(historique, res[1])
		        det = getDeterminant(res[1])
	 			    if det == "Le" then
           		print(valeur,"est la capitale du", res[1])
           	else
           		print(valeur,"est la capitale de",det,res[1])
          	end
		      end
        end


    		if #question["#guerre"] ~= 0 then
		    	local guerre = question:tag2str("#Guerre")[1]
			    colonne="guerre"
			    local res=getCountryFromTable(colonne, guerre)

    			if res ~= nil then
		    		if  #res == 0 then
	          	print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
		  	  	else
	  	  	    table.insert(historique, res[1])
		 	  	    print("Les pays sont:")
		          for k,v in pairs(res) do
			        	print(res[k])
			        end
			    	end
			    end
		    end

        if #question["#continent"] ~= 0 then
				  valeur = question:tag2str("#question", "#infoName")[1]
			    colonne = "continent"
  			  local res = getCountryName(colonne, valeur)

	  		  if #res == 0 then
            print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
			    else
            print("Les pays du continent", valeur,"sont:")
	            for i,elem in ipairs(res) do
    		        det = getDeterminant(elem)
	      	      print(det,elem)
    	  	  	  table.insert(historique, elem)
  	          end
			    end
			  end

        if #question["#monnaie"] ~= 0 then
				  valeur = question:tag2str("#question", "#infoName")[1]
          valeur = valeur:lower()
		  		colonne = "monnaie"
  			  local res = getCountryName(colonne, valeur)

          if #res == 0 then
            print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
	  	  	elseif #res == 1 then
	  	  	  table.insert(historique, res[1])
		        det = getDeterminant(res[1])
	 		      print("Un seul pays a comme monnaie",valeur,",c'est",det,res[1])
	  	  	else
		        det = getDeterminant(res[1])
		        print("Les pays qui ont", valeur,"comme monnaie sont:")
	            for i,elem in ipairs(res) do
    		        det = getDeterminant(elem)
	      	      print(det,elem)
    	  	  	  table.insert(historique, elem)
  	          end
			    end
  			end

        if #question["#langue"] ~= 0 then
				  valeur = question:tag2str("#question", "#infoName")[1]
          valeur = valeur:lower()
		  		colonne = "langue"
  			  local res = getCountryName(colonne, valeur)

          if #res == 0 then
            print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
	  	  	elseif #res == 1 then
	  	  	  table.insert(historique, res[1])
		        det = getDeterminant(res[1])
	 		      print("Un seul pays a comme langue",valeur,",c'est",det,res[1])
	  	  	else
		        det = getDeterminant(res[1])
		        print("Les pays qui ont", valeur,"comme langue sont:")
	            for i,elem in ipairs(res) do
    		        det = getDeterminant(elem)
	      	      print(det,elem)
    	  	  	  table.insert(historique, elem)
  	          end
			    end
  			end




      else
        if #historique ~= 0  then
          ligne = historique[#historique]

          if #question["#capitale"] ~= 0 then
					  colonne = "capitale"
					  local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

					  if res == 0 then
              print("Désolé, je n'ai pas cette information")
					  elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a comme capitales : ")
	            for i,elem in ipairs(res) do
	      	      print(elem)
	            end
	          else
              print(det,ligne, "a", res, "pour capitale")
					  end
			    end

			    if #question["#continent"] ~= 0 then
					  colonne = "continent"
					  local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

  					if res == 0 then
              print("Désolé, je n'ai pas cette information")
		  			elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "est sur plusieurs contients à savoir : ")
	            for i,elem in ipairs(res) do
	      	      print(elem)
  	          end
	          else
              print(det,ligne, "appartient au continent", res)
			  		end
			    end

  			  if #question["#guerre"] ~= 0 then
		  			colonne = "guerre"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a connu plusieurs guerres. Voici la liste :")
	            for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              print(det,ligne, "a connu une seule guerre qui est:", res)
					  end
			    end

  			  if #question["#superficie"] ~= 0 then
		  			colonne = "superficie"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs superficies qui sont :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              if det == "Le" then
                print("La superficie du", ligne,"est de:",res)
              else
                print("La superficie de",det,ligne,"est de:",res)
              end
					  end
			    end

			    if #question["#population"] ~= 0 then
		  			colonne = "population"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs nombre d'habitants à savoir :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              if det == "Le" then
                print("Le nombre d'habitants du", ligne,"est de:",res)
              else
                print("Le nombre d'habitants de",det,ligne,"est de:",res)
              end
					  end
			    end

  			  if #question["#monnaie"] ~= 0 then
		  			colonne = "monnaie"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "utilise plusieurs monnaies qui sont :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              print(det,ligne, "a comme monnaie :", res)
					  end
  			  end

	  		  if #question["#langue"] ~= 0 then
			  		colonne = "langue"
				  	local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs langues officielles qui sont :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              print(det,ligne, "a comme langue officielle :", res)
					  end
  			  end

  			  if #question["#paysFrontaliers"] ~= 0 then
		  			colonne = "paysFrontaliers"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              if(det == "Le") then
                print("Les pays frontaliers du",ligne, "sont :")
  	            for i,elem in ipairs(res) do
  	              local dt = getDeterminant(elem)
	        	      print(dt,elem)
	              end
              else
                print("Les pays frontaliers de",det,ligne, "sont :")
  	            for i,elem in ipairs(res) do
	        	      print(elem)
	              end
              end
	          else
              print(ligne, "a un seul pays frontalier :", res)
					  end
			    end

  			  if #question["#autreNoms"] ~= 0 then
		  			colonne = "autreNoms"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              if det == "Le" then
                print("Les autres noms du",ligne, "sont :")
	              for i,elem in ipairs(res) do
	      	        print(elem)
	              end
              else
                print("Les autres noms de",det,ligne, "sont :")
	              for i,elem in ipairs(res) do
	      	        print(elem)
	              end
              end
	          else
              print(ligne, "a comme autre nom:", res)
					  end
			    end

  			  if #question["#colonisateur"] ~= 0 then
		  			colonne = "colonisateur"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              if det == "Le" then
               print("Les colonisateurs du",ligne, "sont :")
	              for i,elem in ipairs(res) do
  	        	    print(elem)
	              end
              else
                print("Les colonisateurs de",det,ligne, "sont :")
	              for i,elem in ipairs(res) do
    	      	    print(elem)
  	            end
              end
	          else
              print(ligne, "a été colonisé par :", res)
				  	end
			    end

  			  if #question["#revolution"] ~= 0 then
		  			colonne = "revolution"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a connu plusieurs révolutions à savoir:")
	            for i,elem in ipairs(res) do
	      	      print(elem)
  	          end
	          else
              print(det,ligne, "a connu une révolution à savoir :", res)
			  		end
			    end

  			  if #question["#independance"] ~= 0 then
		  			colonne = "independance"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	    			if res == 0 then
              print("Désolé, je n'ai pas cette information")
					  elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a connu plusieurs dates d'indépendance à savoir :")
  	          for i,elem in ipairs(res) do
	        	    for j,elm in ipairs(elem) do
	          	    print(elm)
  	            end
	            end
	          else
              print(det,ligne, "a eu son indépendance le :", res)
					  end
			    end

        else
  	  	  print("Je n'ai pas assez d'informations pour répondre à votre question")
        end
      end




    elseif #question["#questionComparaison"] ~= 0 then
        if #historique ~= 0  then
          tableau = historique

          if #question["#superficie"] ~= 0 and (#question["#min"] ~= 0 or #question["#max"] ~= 0) then
	  				if #question["#min"] ~= 0 then
	  				  comp = "min"
	          else
	  				  comp = "max"
	          end
		  			colonne = "superficie"

			  		local res = getFromComparison(tableau, colonne, comp)

			  		if res == 0 then
              print("Désolé, je ne connais pas les superficies de ces pays.")
            else
              local det = getDeterminant(res)
              if #question["#min"] ~= 0 then
                print("Le pays ayant la plus petite superficie est ",det,res)
	            else
                print("Le pays ayant la plus grande superficie est ",det,res)
	            end
            end

          elseif #question["#population"] ~= 0 and (#question["#min"] ~= 0 or #question["#max"] ~= 0) then
	  				if #question["#min"] ~= 0 then
	  				  comp = "min"
	          else
	  				  comp = "max"
	          end
		  			colonne = "population"

			  		local res = getFromComparison(tableau, colonne, comp)

			  		if res == 0 then
              print("Désolé, je ne connais pas les nombres d'habitants de ces pays.")
            else
              local det = getDeterminant(res)
              if #question["#min"] ~= 0 then
                print("Le pays ayant la plus petite population est ",det,res)
	            else
                print("Le pays ayant la plus grande population est ",det,res)
	            end
            end

					else
    	  	  print("Je ne peux pas comparer ce type d'élément. Reformulez votre question")
			    end

        else
  	  	  print("Vous devez parler d'un pays d'abord !")
        end


      elseif #question["#questionBinaire"] ~= 0 then
          local payConsultant
          local champConsultant
          local result
          local info
          local flag=0
          if #question["#nomPays"] ~= 0 and #question["#champsDetecter"] ~= 0  then
             payConsultant = question:tag2str("#nomPays")[1]
             champConsultant = question:tag2str("#champsDetecter")[1]
             if champConsultant~="personnage" and champConsultant~="revolution" and champConsultant~="independance" and champConsultant~="evenement" then 
                info = question:tag2str("#info")[1]
                result = getChampParPay(payConsultant,champConsultant)
                count=0
                for k,v in pairs(result) do
                  count = count+1
                end
                if count==0 then
                  print("C'est un quetion tres difficile. Franchement je ne sait pas")
                else
                for i,v in ipairs(result) do
                  if v==string.lower(info) and flag~=1 then
                    flag=1
                    print("oui, Vous etes tres intelligent")
                  elseif string.find(string.lower(info),v) ~= nil then
                    flag=1
                    print("oui,", v,"C'est bon")              
                  end
                end
                if(flag==0) then
                  print("Non, c'est pas comme ca")
                end
              end
             else  

             end  

          end
          
        





    elseif #question["#questionEvenement"] ~= 0 then
      --getEvents("France", 1993, 1999)
	  	ligne = question:tag2str("#nomPays")[1]
	  	if ligne ~= nil then
	    	local precision
  	  	local result

	  	  if #question["#annee1"] == 1 then
          annee = question:tag2str("#annee1")[1]
          precision = "en"
          result = getEvents(ligne, annee, precision)

          if result == -1 then
            print("Ce pays n'a connu aucun évènement.")
          else
            if #result ~= 0 then
              print("Les évènements qui ont eu lieu en : ", annee, "sont:")
              for k,v in pairs(result) do
                print(v[1], "--", v[2])
              end
            else
              print("Aucun évènement ne rentre dans cette période")
            end
          end

	  	  elseif #question["#annee2"] == 1 and #question["#annee3"] == 1 then
          local annee1, annee2
          precision = "entre"

          if question:tag2str("#annee2")[1] < question:tag2str("#annee3")[1] then
            annee1 = question:tag2str("#annee2")[1]
            annee2 = question:tag2str("#annee3")[1]
          else
            annee1 = question:tag2str("#annee3")[1]
            annee2 = question:tag2str("#annee2")[1]
          end
          result = getEvents(ligne, annee1, annee2, precision)

          if result == -1 then
            print("Ce pays n'a connu aucun évènement.")
          else
            if #result ~= 0 then
              print("Les évènements qui ont eu lieu entre : ", annee1, "et", annee2, "sont:")
              for k,v in pairs(result) do
                print(v[1], "--", v[2])
              end
            else
              print("Aucun évènement ne rentre dans cette période")
            end
          end

	  	  elseif #question["#annee4"] == 1 then
          annee = question:tag2str("#annee4")[1]
          precision = "après"
          result = getEvents(ligne, annee, precision)

          if result == -1 then
            print("Ce pays n'a connu aucun évènement.")
          else
            if #result ~= 0 then
              print("Les évènements qui ont eu lieu après : ", annee, "sont:")
              for k,v in pairs(result) do
                print(v[1], "--", v[2])
              end
            else
              print("Aucun évènement ne rentre dans cette période")
            end
          end

	  	  elseif #question["#annee5"] == 1 then
          annee = question:tag2str("#annee5")[1]
          precision = "avant"
          result = getEvents(ligne, annee, precision)

          if result == -1 then
            print("Ce pays n'a connu aucun évènement.")
          else
            if #result ~= 0 then
              print("Les évènements qui ont eu lieu avant : ", annee, "sont:")
              for k,v in pairs(result) do
                print(v[1], "--", v[2])
              end
            else
              print("Aucun évènement ne rentre dans cette période")
            end
          end

	  	  else
	  	    print("Je ne comprend pas bien la période donnée. Elle doit être en année")
	  	  end


	  	else
        print("Vous devez spécifier un pays dans votre question.")
	  	end





		else
			print("Je ne comprends pas votre question.")
		end

	end
	print("Au revoir!")
end


getInput()

--[[

    elseif #question["#questionPays"] ~= 0 then


      if #question["#capitale"] ~= 0 then
			  valeur = question:tag2str("#questionPays", "#infoName")[1]
			  colonne = "capitale"
			  local res = getCountryName(colonne, valeur)

				if #res == 0 then
           print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
				else
	  	    det = getDeterminant(res[1])
	  			if det == "Le" then
            print(valeur,"est la capitale du", res[1])
             else
                print(valeur,"est la capitale de",det,res[1])
              end
					  end
			  end


      end

]]
