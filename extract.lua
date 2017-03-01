dark = require("dark")

dofile("common.lua")
dofile("fonctions.lua")



local dbt = {}
local gentiles_country = dofile("gentiles_country.txt")
local personnages = {}

for fichier in os.dir("country_update") do

	local pays = {}
	pays.guerre = {}
	pays.independance = {}
	pays.colonisateur = {}
	pays.revolution = {}
	pays.evenement = {}
	pays.autreNoms = {}
	pays.paysFrontaliers = {}



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
        if curCountry ~= 0
        	then
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

      if #seq["#continent"] ~= 0
      		then
      			if not pays.continent
      			 then
      			    pays.continent = seq:tag2str("#continent", "#continentName")[1]
      			end

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

        if #seq["#personnage"] ~= 0
      	 then
      	 	nom  =  seq:tag2str("#personnage","#personne")[1]
      	 	country = gentiles_country[seq:tag2str("#personnage","#nomPays")[1] ]

      	 	if(not personnages[nom])
      	 		then
      	 		  personnage = {
			          ["fonction"] = {},
			          ["paysPersonnage"] = country,
			          ["paysLiens"] = {}
	      		 }

	      		 table.insert(personnage["fonction"] ,  transformPoste(seq:tag2str("#personnage","#poste")[1]))
	        	  if country ~= curCountry then
	        	     table.insert(personnage["paysLiens"] , curCountry  )
	        	 end

	        	 personnages[nom]= personnage
      	 	else

      	 	 local fonction = transformPoste(seq:tag2str("#personnage","#poste")[1])
      	 	  if table.contains(personnages[nom]["fonction"], fonction) == false
        			then
        				table.insert(personnages[nom]["fonction"] , fonction  )
        		end
      	 	 end

      	 	 if not personnages[nom]["paysPersonnage"]
	    			then
	    				personnages[nom]["paysPersonnage"] = country
	    	 end

      	 	 if  table.contains(personnages[nom]["paysLiens"], curCountry) == false
      	 	  then
      	 	    table.insert(personnages[nom]["paysLiens"] , curCountry  )
      	 	 end

	     end

	    if  #seq["#personnage3"] ~= 0
	     then
	     	country = gentiles_country[seq:tag2str("#personnage3","#gentiles")[1]]
	        nom  =  seq:tag2str("#personnage3","#personne")[1]
      	 	if(not personnages[nom])
      	 		then
      	 		  personnage = {
			          ["fonction"] = {},
			          ["paysPersonnage"] = country ,
			          ["paysLiens"] = {}
	      		 }

	      		 table.insert(personnage["fonction"] , transformPoste( seq:tag2str("#personnage3","#poste")[1] ) )
	        	 if country ~= curCountry then
	        	     table.insert(personnage["paysLiens"] , curCountry  )
	        	 end

	        	 personnages[nom]= personnage
      	 	else

      	 	  local fonction = transformPoste(seq:tag2str("#personnage3","#poste")[1])
      	 	  if table.contains(personnages[nom]["fonction"], fonction) == false
        			then
        				table.insert(personnages[nom]["fonction"] , fonction  )
        	  end
	    	 if not personnages[nom]["paysPersonnage"]
	    			then
	    				personnages[nom]["paysPersonnage"] = country
	    	 end

      	 	 if table.contains(personnages[nom]["paysLiens"], curCountry) == false
      	 	  then
      	 	    table.insert(personnages[nom]["paysLiens"] , curCountry  )
      	 	 end

      	 	 end

	     end

	    if  #seq["#personnage2"] ~= 0
	     then
        	nom  =  seq:tag2str("#personnage2","#personne")[1]
      	 	if(not personnages[nom])
      	 		then
      	 		  personnage = {
			          ["fonction"] = {},
			          ["paysLiens"] = {}
	      		 }

	      		 table.insert(personnage["fonction"] , transformPoste( seq:tag2str("#personnage2","#poste")[1] ))
	        	 table.insert(personnage["paysLiens"] , curCountry  )
	        	 personnages[nom]= personnage
      	 	else
      	 	 local fonction =  transformPoste(seq:tag2str("#personnage2","#poste")[1])
      	 	 if table.contains(personnages[nom]["fonction"], fonction) == false
        			then
        				table.insert(personnages[nom]["fonction"] , fonction  )
        		end
      	 	 end

      	 	 if  table.contains(personnages[nom]["paysLiens"], curCountry) == false
      	 	   then
      	 	    table.insert(personnages[nom]["paysLiens"] , curCountry  )
      	 	 end

	    end

			if #seq["#revolution"] ~= 0
			 then
        		for i = 1, #seq:tag2str("#revolution") do
        			if seq:tag2str("#revolution","#time")[i]~=nil
        				then
        				date = seq:tag2str("#revolution","#time")[i]
        			else
        				date = nil
        		end
        		value = {}
        		value[1] = datePreTraite(date)
        		value[2]=seq:tag2str("#revolution")[i]
        		if table.contains(pays.revolution, value) == false
        			then
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
        				value = "Russie"
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
dbt["personnages"]=personnages


local out = io.open("dataBase.txt", "w")
out:write("return ")
out:write(serialize(dbt))
out:close()


