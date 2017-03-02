dark = require("dark")


dofile("common.lua")
dofile("fonctions.lua")

-- Fonction pour récupérer la question de l'utilisateur
function getInput()
	print("EISD - Histoire pour tous\n")
  historique = {}
  profondeur = {}
  focusChamps = ""
	while true do
		print("Bonjour! Que voulez vous savoir? (ou appuyer q pour quitter)\n")

		question = io.read()
		if question == "q" or question == "Q"  then
			break;
		end
    question = question:gsub("(%p)", " %1 ")
		question = dark.sequence(question)
		pipe(question)
		local ligne
		local colonne
		if (#question["#question"] ~= 0 and #question["#questionEvenement"] == 0) or
		 (#question["#questionComplexe"] ~= 0 and focusChamps ~= "") then

      if #question["#nomPays"] ~= 0 then

        if historique[question:tag2str("#nomPays")[1]] == nil then
          historique[question:tag2str("#nomPays")[1]] = {}
        end

        table.insert(profondeur, 1, question:tag2str("#nomPays")[1])
		    ligne = question:tag2str("#nomPays")[1]

        --[[for k,v in pairs(historique) do
          print(k)
        end]]

			  if #question["#capitale"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "capitale") then
					  colonne = "capitale"
					  focusChamps = "capitale"
					  local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

					  if res == 0 then
              print("Désolé, je n'ai pas cette information")
					  elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a comme capitales : ")
	            historique[ligne].capitale = res
	            for i,elem in ipairs(res) do
	      	      print(elem)
	            end
	          else
	            historique[ligne].capitale = res
              print(det,ligne, "a pour capitale",res)
					  end
			  end

			  if #question["#continent"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "continent") then
				  	ligne = question:tag2str("#nomPays")[1]
					  colonne = "continent"
					  focusChamps = "continent"
					  local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

  					if res == 0 then
              print("Désolé, je n'ai pas cette information")
		  			elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "est sur plusieurs contients à savoir : ")
	            historique[ligne].continent = res
	            for i,elem in ipairs(res) do
	      	      print(elem)
  	          end
	          else
	            historique[ligne].continent = res
              print(det,ligne, "appartient au continent",res)
			  		end
			  end

  			if #question["#guerre"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "guerre") then
	  			ligne = question:tag2str("#nomPays")[1]
		  		colonne = "guerre"
				  focusChamps = "guerre"
			  	local res = getFromCountry(ligne, colonne)
					local det = getDeterminant(ligne)

	  			if res == 0 then
          	print("Désolé, je n'ai pas cette information")
			  	elseif res == -1 then
          	print("Désolé, je ne comprends pas de quel pays vous parlez")
          elseif type(res) == "table" then
          	print(det,ligne, "a connu plusieurs guerres. Voici la liste :")
            historique[ligne].guerre = res
	        	for i,elem in ipairs(res) do
	         		print(elem)
	        	end
	        else
	          historique[ligne].guerre = res
          	print(det,ligne, "a connu une seule guerre qui est:", res)
					end
			  end

  			if #question["#superficie"] ~= 0  or (#question["#questionComplexe"] ~= 0 and focusChamps == "superficie") then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "superficie"
					  focusChamps = "superficie"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs superficies qui sont :")
	            historique[ligne].superficie = res
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
	            historique[ligne].superficie = res
              if det == "Le" then
                print("La superficie du", ligne,"est de:",res)
              else
                print("La superficie de",det,ligne,"est de:",res)
              end
					  end
			  end

			  if #question["#population"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "population") then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "population"
					  focusChamps = "population"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs nombre d'habitants. Etonnant! Mais voici la liste :")
	            historique[ligne].population = res
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
	            historique[ligne].population = res
	            if det == "Le" then
                print("Le nombre d'habitants du", ligne,"est de:",res)
              else
                print("Le nombre d'habitants de",det,ligne,"est de:",res)
              end
					  end
			  end

  			if #question["#monnaie"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "monnaie") then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "monnaie"
					  focusChamps = "monnaie"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "utilise plusieurs monnaies qui sont :")
	            historique[ligne].monnaie = res
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
	            historique[ligne].monnaie = res
              print(det,ligne, "a comme monnaie :", res)
					  end
  			end

	  		if #question["#langue"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "langue") then
		  			ligne = question:tag2str("#nomPays")[1]
			  		colonne = "langue"
					  focusChamps = "langue"
				  	local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs langues officielles qui sont :")
	            historique[ligne].langue = res
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
	            historique[ligne].langue = res
              print(det,ligne, "a comme langue officielle :", res)
					  end
  			end

  			if #question["#paysFrontaliers"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "paysFrontaliers") then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "paysFrontaliers"
					  focusChamps = "paysFrontaliers"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
	            historique[ligne].paysFrontaliers = res
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
	            historique[ligne].paysFrontaliers = res
              print(det,ligne, "a un seul pays frontalier :", res)
					  end
			  end

  			if #question["#autreNoms"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "autreNoms") then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "autreNoms"
					  focusChamps = "autreNoms"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
	            historique[ligne].autreNoms = res
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
	            historique[ligne].autreNoms = res
              print(det,ligne, "a comme autre nom:", res)
					  end
			  end

  			if #question["#colonisateur"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "colonisateur") then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "colonisateur"
					  focusChamps = "colonisateur"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
	            historique[ligne].colonisateur = res
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
	            historique[ligne].colonisateur = res
              print(det,ligne, "a été colonisé par :", res)
				  	end
			  end

  			if #question["#revolution"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "revolution") then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "revolution"
					  focusChamps = "revolution"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
	            historique[ligne].revolution = res
              print(det,ligne, "a connu plusieurs révolutions à savoir:")
	            for i,elem in ipairs(res) do
	      	      print(elem)
  	          end
	          else
	            historique[ligne].revolution = res
              print(det,ligne, "a connu une révolution à savoir :", res)
			  		end
			  end

  			if #question["#independance"] ~= 0 or (#question["#questionComplexe"] ~= 0 and focusChamps == "independance") then
	  				ligne = question:tag2str("#nomPays")[1]
		  			colonne = "independance"
					  focusChamps = "independance"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	    			if res == 0 then
              print("Désolé, je n'ai pas cette information")
					  elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
	            historique[ligne].independance = res
              print(det,ligne, "a connu plusieurs dates d'indépendance à savoir :")
  	          for i,elem in ipairs(res) do
	        	    for j,elm in ipairs(elem) do
	          	    print(elm)
  	            end
	            end
	          else
	            historique[ligne].independance = res
              print(det,ligne, "a eu son indépendance le :", res)
					  end
			  end





      else
        local cpt = 0
        for k,v in pairs(historique) do
          cpt = cpt+1
        end
        if cpt ~= 0  then
          ligne = profondeur[1]
   	  	  --historique[ligne] = {}
 	    	  	table.insert(profondeur, 1, ligne)

          if #question["#capitale"] ~= 0 then
					  colonne = "capitale"
					  focusChamps = "capitale"
					  local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

					  if res == 0 then
              print("Désolé, je n'ai pas cette information")
					  elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].capitale = res
              print(det,ligne, "a comme capitales : ")
	            for i,elem in ipairs(res) do
	      	      print(elem)
	            end
	          else
              historique[ligne].capitale = res
              print(det,ligne, "a", res, "pour capitale")
					  end
			    end

			    if #question["#continent"] ~= 0 then
					  colonne = "continent"
					  focusChamps = "continent"
					  local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

  					if res == 0 then
              print("Désolé, je n'ai pas cette information")
		  			elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].continent = res
              print(det,ligne, "est sur plusieurs contients à savoir : ")
	            for i,elem in ipairs(res) do
	      	      print(elem)
  	          end
	          else
              historique[ligne].continent = res
              print(det,ligne, "appartient au continent", res)
			  		end
			    end

  			  if #question["#guerre"] ~= 0 then
		  			colonne = "guerre"
					  focusChamps = "guerre"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].guerre = res
              print(det,ligne, "a connu plusieurs guerres. Voici la liste :")
	            for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              historique[ligne].guerre = res
              print(det,ligne, "a connu une seule guerre qui est:", res)
					  end
			    end

  			  if #question["#superficie"] ~= 0 then
		  			colonne = "superficie"
					  focusChamps = "superficie"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].superficie = res
              print(det,ligne, "a plusieurs superficies qui sont :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              historique[ligne].superficie = res
              if det == "Le" then
                print("La superficie du", ligne,"est de:",res)
              else
                print("La superficie de",det,ligne,"est de:",res)
              end
					  end
			    end

			    if #question["#population"] ~= 0 then
		  			colonne = "population"
					  focusChamps = "population"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              historique[ligne].population = res
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              print(det,ligne, "a plusieurs nombre d'habitants à savoir :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              historique[ligne].population = res
              if det == "Le" then
                print("Le nombre d'habitants du", ligne,"est de:",res)
              else
                print("Le nombre d'habitants de",det,ligne,"est de:",res)
              end
					  end
			    end

  			  if #question["#monnaie"] ~= 0 then
		  			colonne = "monnaie"
					  focusChamps = "monnaie"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].monnaie = res
              print(det,ligne, "utilise plusieurs monnaies qui sont :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              historique[ligne].monnaie = res
              print(det,ligne, "a comme monnaie :", res)
					  end
  			  end

	  		  if #question["#langue"] ~= 0 then
			  		colonne = "langue"
					  focusChamps = "langue"
				  	local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].langue = res
              print(det,ligne, "a plusieurs langues officielles qui sont :")
  	          for i,elem in ipairs(res) do
	        	    print(elem)
	            end
	          else
              historique[ligne].langue = res
              print(det,ligne, "a comme langue officielle :", res)
					  end
  			  end

  			  if #question["#paysFrontaliers"] ~= 0 then
		  			colonne = "paysFrontaliers"
					  focusChamps = "paysFrontaliers"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].paysFrontaliers = res
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
              historique[ligne].paysFrontaliers = res
              print(ligne, "a un seul pays frontalier :", res)
					  end
			    end

  			  if #question["#autreNoms"] ~= 0 then
		  			colonne = "autreNoms"
					  focusChamps = "autreNoms"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].autreNoms = res
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
              historique[ligne].autreNoms = res
              print(ligne, "a comme autre nom:", res)
					  end
			    end

  			  if #question["#colonisateur"] ~= 0 then
		  			colonne = "colonisateur"
					  focusChamps = "colonisateur"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].colonisateur = res
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
              historique[ligne].colonisateur = res
              print(ligne, "a été colonisé par :", res)
				  	end
			    end

  			  if #question["#revolution"] ~= 0 then
		  			colonne = "revolution"
					  focusChamps = "revolution"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	  				if res == 0 then
              print("Désolé, je n'ai pas cette information")
			  		elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].revolution = res
              print(det,ligne, "a connu plusieurs révolutions à savoir:")
	            for i,elem in ipairs(res) do
	      	      print(elem)
  	          end
	          else
              historique[ligne].revolution = res
              print(det,ligne, "a connu une révolution à savoir :", res)
			  		end
			    end

  			  if #question["#independance"] ~= 0 then
		  			colonne = "independance"
					  focusChamps = "independance"
			  		local res = getFromCountry(ligne, colonne)
					  local det = getDeterminant(ligne)

	    			if res == 0 then
              print("Désolé, je n'ai pas cette information")
					  elseif res == -1 then
              print("Désolé, je ne comprends pas de quel pays vous parlez")
            elseif type(res) == "table" then
              historique[ligne].independance = res
              print(det,ligne, "a connu plusieurs dates d'indépendance à savoir :")
  	          for i,elem in ipairs(res) do
	        	    for j,elm in ipairs(elem) do
	          	    print(elm)
  	            end
	            end
	          else
              historique[ligne].independance = res
              print(det,ligne, "a eu son indépendance le :", res)
					  end
			    end

        else
  	  	  print("Je n'ai pas assez d'informations pour répondre à votre question")
        end
      end






      -- Si dans la question on a un lexique de pays(voir lexicon)
    elseif #question["#questionPays"] ~= 0 then

        -- Vérifier toutes les infoName d'abord
	  	  if #question["#capitale"] ~= 0 then
	  	    valeur = question:tag2str("#questionPays", "#infoName")[1]
	  	    if valeur == nil then
	  	      print("Le nom donné doit commencer par une majuscule. ")
	  	    else
			      colonne = "capitale"
					  focusChamps = "capitale"
  			    local res = getCountryName(colonne, valeur)

  	  		  if #res == 0 then
            	print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
	    	  	else
  	    	  	table.insert(profondeur, 1, res[1])
	    	  	  if(historique[res[1]] == nil) then
  	    	  	  historique[res[1]] = {}
              end
              historique[res[1]].capitale = valeur
		          det = getDeterminant(res[1])
	 			      if det == "Le" then
             		print(valeur,"est la capitale du", res[1])
           	  else
           		  print(valeur,"est la capitale de",det,res[1])
          	  end
		        end

	  	    end
        end


    		if #question["#guerre"] ~= 0 then
		    	local guerre = question:tag2str("#Guerre")[1]
			    colonne="guerre"
				  focusChamps = "guerre"
			    local res=getCountryFromTable(colonne, guerre)

    			if res ~= nil then
		    		if  #res == 0 then
	          	print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
		  	  	else
		 	  	    print("Les pays sont:")
		          for k,v in pairs(res) do
    	    	  	table.insert(profondeur, 1, res[k])
	      	  	  if(historique[res[k]] == nil) then
    	    	  	  historique[res[k]] = {}
                end
                historique[res[k]].guerre = guerre
			        	print(res[k])
			        end
			    	end
			    end
		    end

        if #question["#continent"] ~= 0 then
				  valeur = question:tag2str("#questionPays", "#infoName")[1]
				  if valeur == nil then
	  	      print("Le nom donné doit commencer par une majuscule. ")
	  	    else
  			    colonne = "continent"
					  focusChamps = "continent"
    			  local res = getCountryName(colonne, valeur)

	    		  if #res == 0 then
              print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
			      else
              print("Les pays du continent", valeur,"sont:")
	              for i,elem in ipairs(res) do
	        	  	  if(historique[elem] == nil) then
      	    	  	  historique[elem] = {}
                  end
      	    	  	table.insert(profondeur, 1, elem)
                  historique[elem].continent = valeur
    		          det = getDeterminant(elem)
	      	        print(det,elem)
  	            end
			      end
			    end
			  end

        if #question["#monnaie"] ~= 0 then
				  valeur = question:tag2str("#questionPays", "#infoName")[1]
				  if valeur == nil then
	  	      print("Le nom donné doit commencer par une majuscule. ")
	  	    else
            valeur = valeur:lower()
	  	  		colonne = "monnaie"
					  focusChamps = "monnaie"
  	  		  local res = getCountryName(colonne, valeur)

            if #res == 0 then
              print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
	  	    	elseif #res == 1 then
	    	  	  historique[res[1]] = {}
              historique[res[1]].monnaie = valeur
		          det = getDeterminant(res[1])
	 		        print("Un seul pays a comme monnaie",valeur,",c'est",det,res[1])
	  	  	  else
		          det = getDeterminant(res[1])
		          print("Les pays qui ont", valeur,"comme monnaie sont:")
	              for i,elem in ipairs(res) do
    		          det = getDeterminant(elem)
  	      	      print(det,elem)
	        	  	  if(historique[elem] == nil) then
      	    	  	  historique[elem] = {}
                  end
      	    	  	table.insert(profondeur, 1, elem)
                  historique[elem].monnaie = valeur
  	            end
			      end
			    end
  			end

        if #question["#langue"] ~= 0 then
				  valeur = question:tag2str("#questionPays", "#infoName")[1]
				  if valeur == nil then
	  	      print("Le nom donné doit commencer par une majuscule. ")
	  	    else
            valeur = valeur:lower()
	  	  		colonne = "langue"
					  focusChamps = "langue"
  	  		  local res = getCountryName(colonne, valeur)

            if #res == 0 then
              print("Désolé, je n'ai trouvé aucun pays correspondant à votre demande")
	    	  	elseif #res == 1 then
	    	  	  historique[res[1]] = {}
              historique[res[1]].langue = valeur
		          det = getDeterminant(res[1])
	 		        print("Un seul pays a comme langue",valeur,",c'est",det,res[1])
	  	  	  else
		          det = getDeterminant(res[1])
  		        print("Les pays qui ont", valeur,"comme langue sont:")
	              for i,elem in ipairs(res) do
      		        det = getDeterminant(elem)
	        	      print(det,elem)
	        	  	  if(historique[elem] == nil) then
      	    	  	  historique[elem] = {}
                  end
      	    	  	table.insert(profondeur, 1, elem)
                  historique[elem].langue = valeur
  	            end
			      end
  			  end
        end





    elseif #question["#questionComparaison"] ~= 0 then
        local cpt = 0
        for k,v in pairs(historique) do
          cpt = cpt+1
        end
        if cpt ~= 0  then
          tableau = {}

          if #profondeur <= 5 then
            tableau = profondeur
          else
            for i = 1, 5 do
              print(profondeur[i])
              table.insert(tableau, profondeur[i])
            end
          end


          if #question["#superficie"] ~= 0 and (#question["#min"] ~= 0 or #question["#max"] ~= 0) then
	  				if #question["#min"] ~= 0 then
	  				  comp = "min"
	          else
	  				  comp = "max"
	          end
		  			colonne = "superficie"
					  focusChamps = "superficie"

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
					  focusChamps = "population"

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
          if #question["#nomPays"] ~= 0 then
            payConsultant = question:tag2str("#nomPays")[1]
            if #question["#capitale"] ~= 0 then
             champConsultant = "capitale"
            elseif #question["#paysFrontaliers"] ~= 0 then
             champConsultant = "paysFrontaliers"
            elseif #question["#monnaie"] ~= 0 then
             champConsultant = "monnaie"
            elseif #question["#langue"] ~= 0 then
             champConsultant = "langue"
            elseif #question["#population"] ~= 0 then
             champConsultant = "population"
            elseif #question["#continent"] ~= 0 then
             champConsultant = "continent"
            elseif #question["#superficie"] ~= 0 then
             champConsultant = "superficie"
            elseif #question["#peuple"] ~= 0 then
             champConsultant = "peuple"
            elseif #question["#colonisateur"] ~= 0 then
             champConsultant = "colonisateur"
            elseif #question["#autreNoms"] ~= 0 then
             champConsultant = "autreNoms"
            end
            info1 = question:tag2str("#info1")[1]
            info2 = question:tag2str("#info2")[1]
            if champConsultant=="paysFrontaliers" then
              chercheNum = string.find(question:tag2str("#questionBinaire")[1],"frontalier")
              local minPay = 99999
              for i,v in ipairs(question:tag2str("#nomPays")) do
                  payNum = string.find(question:tag2str("#questionBinaire")[1],v,chercheNum)
                  if payNum~=nil and payNum<minPay then
                    minPay = payNum
                    payConsultant = v
                  end
              end
            end
            if string.find(info1,payConsultant) ~= nil then
              info = info2
            else
              info = info1
            end
            result = getChampParPay(payConsultant,champConsultant)
            count=0
            for k,v in pairs(result) do
              count = count+1
            end
            if count==0 then
              print("C'est un question tres difficile. Franchement je ne sais pas")
            else
              for i,v in ipairs(result) do
                if v==string.lower(info) and flag~=1 then
                  flag=1
                  print("oui, Vous etes tres intelligent")
                elseif string.find(string.lower(info),v) ~= nil then
                  flag=1
                  print("oui,", v,"C'est bien ça")
                end
              end
            end
            if(flag==0) then
                print("Non, ce n'est pas vrai")
            end
          else
            print("Je ne comprends pas la qustion")
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
