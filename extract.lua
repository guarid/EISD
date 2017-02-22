dark = require("dark")

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end



function NotPoint(seq, pos)
	return (seq[pos].token ~= "." and seq[pos].token ~= "!" and seq[pos].token ~= "?" and seq[pos].token ~= "^")
end


function datePreTraite(myDate)
	t = {}
	str = ""
	for w in string.gmatch(myDate, "%S+") do     --按照“,”分割字符串
    	if w~="en" and w~="le" and w~="années" then
    		str = str..w
    		str = str.." "
    	end
	end
	return str

end


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
	["#superficie"] = "blue",
	["#organisation"] = "white",
	["#paysFrontaliers"] = "white",
	["#independance"] = "red",
	["#determinant"] = "red",
	["#Guerre"] = "red",
	["#poste"] = "blue",
	["#personnage"] ="white",
	["#personnage2"] ="yellow",
	["#evenement"] = "red",
	["#colonisateur"] = "white"
}

local pipe = dark.pipeline()
pipe:basic()

pipe:model("../model-2.3.0/postag-fr")
pipe:lexicon("#nomPays", "lex/nomPays.txt")
pipe:lexicon("#paysColonisateur", "lex/nomPaysAdjectif.txt")
pipe:lexicon("#prenom", "lex/prenoms.txt")
pipe:lexicon("#personne", "lex/personnages.txt")
pipe:lexicon("#continentName", {"Afrique", "Amérique", "Asie", "Europe", "Océanie"})
pipe:lexicon("#mois", {"janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"})
pipe:lexicon("#pointsCardinaux", {"nord", "sud", "ouest", "est"})
pipe:lexicon("#ocean", {"océan Pacifique", "océan Atlantique", "océan Indien", "océan Arctique"})
pipe:lexicon("#colonie",{"colonie","colonisateur","colonialisme","colonisation","colonial","coloniale"})
pipe:lexicon("#articleIndefini",{"du","de la ","de","des"})
pipe:lexicon("#poste",{"roi","duc","grand duc","reine","prince","président de la république ","président de la République ","président","premier ministe","ministre","chef du gouvernement","général","empereur"})


-- Pattern pour détecter une personne en utilisant le lexique des prénoms
pipe:pattern([[
	[#personne
		#prenom [#nom ( /^%u/ /^%u/ | /^%u/ ) ]
	]
]])

-- Pattern pour détecter un nombre
pipe:pattern([[
	[#number
    #d ((#d)+ | ("," #d)?)
	]
]])

-- Pattern pour détecter le déterminant d'un pays
pipe:pattern([[
	[#determinant
    [#det ("La" | "Le" | "L" "'" | "Les")] #nomPays
	]
]])

-- Pattern pour les autres noms(forme plus longues) d'un pays
pipe:pattern([[
	[#autreNoms
    (
      "République"
      |
      "Royaume"
      |
      "Principauté"
    )
    ("populaire" | "démocratique" | "coopérative")? ("de" | "du" | "d" "'" | ) (#nomPays | #POS=ADJ)
	]
]])


-- Pattern pour détecter le continent d'un pays
pipe:pattern([[
	[#continent
    "est" "un" "pays" "d" "'" #continentName
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


-- Pattern pour détecter la capitale d'un pays
pipe:pattern([[
	[#capitale
    (
    "capitale" ("fédérale" | "officielle" | "du" "pays" | "du" "royaume" | ("du" | "de" "la" | "de" "l" "'" ) #nomPays)?

    ("et" ("sa" | ) "plus" "grande" "ville" | "est" "la" "ville" "d" "'" | "politique" "et" "administrative")?
    ("est" | "en" | "," | "à" | )? [#name ( /^%u/ "-" /^%l/ "-" /^%u/ | /^%u/ "-" /^%u/ | /^%u/ "'" /^%u/ | /^%u/ /^%u/ | /^%u/)]
	  )
	  |
	  (
      [#name ( /^%u/ "-" /^%u/ | /^%u/ "'" /^%u/ | /^%u/ /^%u/ | /^%u/)] ("en" "est" | "est" | "pour") ("sa" | "la")*? "capitale"
	  )
	]
]])


-- Pattern pour détecter la langue parlée par un pays
pipe:pattern([[
	[#langue
    "langue" ("officielle" | "nationale" | "principale") (("du" | "de" "la" | "des") #nomPays)?
    ("est" | ",")? ("le" | "l" "'" | "la")? ([#name (#POS=ADJ| #POS=NNC)])
    |
    [#name (#POS=ADJ| #POS=NNC)] ("est" | "étant" "proclamé")? ("la")? "langue" ("officielle" | "nationale")
	]
]])


-- Pattern pour détecter la monnaie utilisée dans un pays
pipe:pattern([[
	[#monnaie
    "monnaie" ("officielle" | "nationale")? ("est"| "était" | ",")? [#name ("le" | "l" "'" | "la") (/^%l/ /^%l/ "-" /^%l/ |/^%l/ /^%l/ | /^%l/)?]
    |
    [#name ("le" | "Le" | "La" | "l" "'" | "L" "'" | "la") (/^%l/ /^%l/ | /^%l/)?] ("est" | "était") ("adopté" "comme" | "resté"| "déjà")? ("sa" | "la")? "monnaie"
	]
]])


-- Pattern pour détecter la population habitant d'un pays
pipe:pattern([[
	[#population
    (#nomPays ("comptait" | "compte" | "comptent") | "Peuplée" | "peuplé" | "peuplée" | "peuplé"
    |
    ("sa"| "Sa" | "La" | "la") "population" | "Y" "résident" | "Avec")
    (/./)* [#nombre  #number ("millions")?]  ("habitants" | "d" "'" "habitants")
	]
]])


-- Pattern pour détecter la superficie d'un pays
pipe:pattern([[
	[#superficie
    "superficie" .+? [#sup  #number ("km" | "kilomètres" | "millions" "de" "km")]
	]
]])


-- Pattern pour détecter les organisations auxquelles appartient d'un pays
pipe:pattern([[
	[#organisation
    ("fait" "partie" | "a" "intégré" | "a" "rejoint" | "est" "membre")
    ("de" | "de" "la" | "du" | "la" | "le" | "l" "'" | )  [#nomOrga #POS=NNP]
	]
]])


-- Pattern pour détecter les pays frontaliers d'un pays
pipe:pattern([[
  [#paysFrontaliers
    (("entouré" | "entourée" | "bordé" | "encadré" | "délimité"| "bordée" | "encadrée" | "délimitée"
    |
    "Entouré" | "Entourée" | "Bordé" | "Encadré" | "Délimité"| "Bordée" | "Encadrée" | "Délimitée") ("par" | "à")?
    |
    "a" "comme" "voisins" | "frontières" ("terrestres")? "avec") .+? "."
  ]
]])


-- Pattern pour détecter les personnages (fonction en rapport à une personne)
pipe:pattern([[
	  [#personnage
	   		(#personne .{0,8}? #poste 	#articleIndefini  #nomPays ) |

	   		(#poste #articleIndefini  #nomPays .{0,8}?   #personne	) |

	   		(#poste #personne #articleIndefini  #nomPays ) |

	   		(#personne  .{0,8}?  "élu" #poste .{0,8}? #nomPays )

	  ]
]])


-- Pattern pour détecter les personnages (fonction en rapport à une personne)
pipe:pattern([[
	  [#personnage2
	   		(#poste .{0,15}? #personne ) | (#personne  .{0,15}? #poste )

	  ]
]])


-- Pattern pour détecter les révolutions ayant eu lieu et la date
pipe:pattern([[
  [#revolution
  	([#time ("le" #date)|(("en"|"années") #number)]) .*? ("révolution" | "Révolution"|"révolte"|"Révolte")
  	|
  	("révolution" | "Révolution"|"révolte"|"Révolte") .*? [#time ("le" #date)|(("en"|"années") #number)]
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
	[#evenement
		@NotPoint*? [#time ("le" #date)|(("en"|"années") #number)] .*? ("." | $ | "!" | "?")
	]
]])


-- Pattern pour détecter un colonisateur en rapport à un évènement d'indépendance
pipe:pattern([[
	[#colonisateur
		(#colonie .*? (#paysColonisateur)+)
		|
		((#paysColonisateur).*?#colonie)
		|
		("contre" .*? (#paysColonisateur)+)
	]
]])


-- Pattern pour détecter une date d'indépendance
pipe:pattern([[
	[#independance
		(
			(
				("un" ("État"|"état") "indépendant")
				|"fondation" [#pays (("le" | "la" | "l" "'") #nomPays)]
				|("devient"|"est"|"soit"|"était") ("indépendante"|"independant")
				|(("l" "'")|"son") "indépendance"
				|"à" "la" "pleine" "souveraineté"
			)
			.*?[#time ("le" #date)|(("en"|"années") #number)]
		)
		|
		(
			[#time ("le" #date)|(("en"|"années") #number)].*?
			(
				"un" ("État"|"état") "indépendant"
				|"fondation" [#pays (("du" | "de" "la" | "des"| "de" "l" "'") #nomPays)]
				|("devient"|"est"|"soit"|"était") ("indépendante"|"independant")
				|(("l" "'")|"son") "indépendance"
				|"à" "la" "pleine" "souveraineté"
			)
		)
	]
]])



local dbt = {}

for fichier in os.dir("country_update") do

	local pays = {}
	pays.guerre = {}
	pays.independance = {}
	pays.colonisateur = {}
	pays.revolution = {}
	pays.evenement = {}
	pays.autreNoms = {}
	pays.paysFrontaliers = {}
	pays.personnage = {}

	for line in io.lines("country_update/"..fichier) do
    line = line:gsub("(%p)", " %1 ")
    --line = line:gsub(" ' ", "'")
    line = line:gsub("qu'", "qu' ")
    line = line:gsub("présidence de", "président")
    line = line:gsub("(%d) , (%d)", "%1,%2")

    if line ~= "" then
			local seq = dark.sequence(line)
      pipe(seq)
      for l1 in io.lines("lex/nomPays.txt") do
        line = line:gsub(" ' ", "'")
        if(l1 == line) then
          curCountry = l1
        end
      end

      if not pays.nom then
        if curCountry ~= 0 then
					pays.nom = curCountry
				end
      end


      if #seq["#autreNoms"] ~= 0 then
        for i = 1, #seq:tag2str("#autreNoms") do
  			  local name = seq:tag2str("#autreNoms","#nomPays")[i]
            if name == pays.nom then
          	  value = seq:tag2str("#autreNoms")[i]
          	  if table.contains(pays.autreNoms, value) == false then
            	  table.insert(pays.autreNoms, value)
              end
            end
        end
			end

      if #seq["#determinant"] ~= 0 and seq:tag2str("#determinant", "#nomPays")[1] == curCountry then
			  pays.determinant = seq:tag2str("#determinant", "#det")[1]
			end

      if #seq["#continent"] ~= 0 then
			  pays.continent = seq:tag2str("#continent", "#continentName")[1]
			end

			if #seq["#capitale"] ~= 0 then
			  pays.capitale = seq:tag2str("#capitale","#name")[1]
			end

			if #seq["#langue"] ~= 0 then
			  pays.langue = seq:tag2str("#langue","#name")[1]
			end

			if #seq["#population"] ~= 0 then
			  local val = seq:tag2str("#population","#nombre")[1]
			  val = val:gsub("millions", "000 000")
			  val = val:gsub(", (%d) 0", "0")
			  pays.population = val
			end

			if #seq["#monnaie"] ~= 0 then
			  pays.monnaie = seq:tag2str("#monnaie","#name")[1]
			end

			if #seq["#superficie"] ~= 0 then
			  local val = seq:tag2str("#superficie","#sup")[1]
			  val = val:gsub("millions", "000 000")
			  val = val:gsub("kilometres", "km")
			  val = val:gsub("kilomètres", "km")
			  pays.superficie = val
			end

      if #seq["#paysFrontaliers"] ~= 0 then
			  for i = 1, #seq:tag2str("#paysFrontaliers", "#nomPays") do
        	value = seq:tag2str("#paysFrontaliers", "#nomPays")[i]
        	if table.contains(pays.paysFrontaliers, value) == false then
        		table.insert(pays.paysFrontaliers, value)
        	end
        end
			end

      if #seq["#personnage"] ~= 0 then
	        personnage = {
	          ["nom"] = seq:tag2str("#personnage","#personne")[1],
	          ["fonction"] = seq:tag2str("#personnage","#poste")[1],
	          ["paysPersonnage"] = seq:tag2str("#personnage","#nomPays")[1]
	        }
	        table.insert(pays.personnage, personnage)



	    elseif  #seq["#personnage2"] ~= 0 then
          personnage = {
	          ["nom"] = seq:tag2str("#personnage2","#personne")[1],
	          ["fonction"] = seq:tag2str("#personnage2","#poste")[1],

	         }
	         table.insert(pays.personnage, personnage)

	    end

			if #seq["#revolution"] ~= 0 then
				local date = seq:tag2str("#revolution","#date")

        if date ~= 0 then
          pays.revolution = {
						["nom"]   = seq:tag2str("#revolution")[1],
						["date"] = seq:tag2str("#revolution","#date")[1]
					}
        end
			end

			if #seq["#revolution"] ~= 0 then
        	for i = 1, #seq:tag2str("#revolution") do
        		date = seq:tag2str("#revolution","#time")[i]
        		value = {}
        		value[1] = datePreTraite(date)
        		value[2]=seq:tag2str("#revolution")[i]
        		if table.contains(pays.revolution, value) == false then
        			table.insert(pays.revolution, value)
        		end
      	  end
      end

			if #seq["#Guerre"] ~= 0 then
        for i = 1, #seq:tag2str("#Guerre") do
        	value = seq:tag2str("#Guerre")[i]
        	if table.contains(pays.guerre, value) == false then
        		table.insert(pays.guerre, value)
        	end
        end
      end

      if #seq["#colonisateur"] ~= 0 then
				value = seq:tag2str("#colonisateur","#paysColonisateur")[1]

				for i = 1, #seq:tag2str("#colonisateur") do
        			value = seq:tag2str("#colonisateur","#paysColonisateur")[i]
        			if value=="française" or value=="français" then
        				value = "France"
        			elseif value=="britannique" or value=="anglais" or value=="anglaise" then
        				value = "Angleterre"
        			elseif value=="espagnol" or value=="espagnole" then
        				value = "Espagne"
        			elseif value=="portugais" or value=="portugaise" then
        				value = "Portugal"
        			elseif value=="allemand" or value=="allemande" then
        				value = "Allemagne"
        			elseif value=="italien" or value=="italienne" then
        				value = "Italie"
        			elseif value=="russe" then
        				value = "Russi"
        			elseif value=="chinois" or value=="chinoise" then
        				value = "Chine"
        			elseif value=="européen" or value=="européenne" then
        				value = "europe"
        			elseif value=="hollandais" or value=="hollandaise" then
        				value = "Hollande"
        			elseif value=="belge" then
        				value = "Belgique"
        			end
        			if table.contains(pays.colonisateur, value)==false then
        			  table.insert(pays.colonisateur,value)
        			end
    			end
			end

      if #seq["#evenement"] ~= 0 then
				for i = 1, #seq:tag2str("#evenement") do
        			date = seq:tag2str("#evenement","#time")[i]
        			value = {}
        			value[1] = datePreTraite(date)
        			value[2]=seq:tag2str("#evenement")[i]
        			table.insert(pays.evenement,value)
    			end
			end


			if #seq["#independance"] ~= 0 then
				for i = 1, #seq:tag2str("#independance") do
        			date = seq:tag2str("#independance","#time")[i]
        			value = {}
        			value[1] = datePreTraite(date)
        			value[2]=seq:tag2str("#independance")[i]
        			table.insert(pays.independance,value)
    			end
			end

      --print(seq:tostring(tags))
	  end
	end

	if pays.nom then
		dbt[pays.nom] = pays
	end

end



local out = io.open("dataBase.txt", "w")
out:write("return ")
out:write(serialize(dbt))
out:close()
