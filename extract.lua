dark = require("dark")

dofile("patterns.lua")
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


      if #seq["#autreNomsPat"] ~= 0 then
        for i = 1, #seq:tag2str("#autreNomsPat") do
  			  local name = seq:tag2str("#autreNomsPat","#nomPays")[i]
            if name == pays.nom then
          	  value = seq:tag2str("#autreNomsPat")[i]
          	  if table.contains(pays.autreNoms, value) == false then
            	  table.insert(pays.autreNoms, value)
              end
            end
        end
			end

      if #seq["#determinant"] ~= 0 and seq:tag2str("#determinant", "#nomPays")[1] == curCountry then
			  pays.determinant = seq:tag2str("#determinant", "#det")[1]
			end

      if #seq["#continentPat"] ~= 0
      		then
      			if not pays.continent
      			 then
      			    pays.continent = seq:tag2str("#continentPat", "#continentName")[1]
      			end

			end

			if #seq["#capitalePat"] ~= 0 then
			  pays.capitale = seq:tag2str("#capitalePat","#name")[1]
			end

			if #seq["#languePat"] ~= 0 then
			  pays.langue = seq:tag2str("#languePat","#name")[1]
			end

			if #seq["#populationPat"] ~= 0 then
		    local val = seq:tag2str("#populationPat","#nombre")[1]
        if val~=nil then
		    	val = val:gsub("millions", "000 000")
			    val = val:gsub(", (%d) 0", "0")
        end
		    pays.population = val
		  end

			if #seq["#monnaiePat"] ~= 0 then
			  pays.monnaie = seq:tag2str("#monnaiePat","#name")[1]
			end

			if #seq["#superficieP"] ~= 0 then
			  local val = seq:tag2str("#superficieP","#sup")[1]
        if val~=nil then
		    	val = val:gsub("millions", "000 000")
			    val = val:gsub("kilometres", "km")
			    val = val:gsub("kilomètres", "km")
        end
			  pays.superficie = val
		  end

      if #seq["#paysFrontaliersPat"] ~= 0 then
			  for i = 1, #seq:tag2str("#paysFrontaliersPat", "#nomPays") do
        	value = seq:tag2str("#paysFrontaliersPat", "#nomPays")[i]
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

       if  #seq["#personnage4"] ~= 0
       then
          nom  =  seq:tag2str("#personnage4","#personne")[1]
          if(not personnages[nom])
            then
              personnage = {           
                ["fonction"] = {},
                ["paysLiens"] = {},
                ["paysPersonnage"] = curCountry
             }
             
             table.insert(personnage["fonction"] , transformPoste( seq:tag2str("#personnage4","#poste")[1] ))
             personnages[nom]= personnage 
          else
           local fonction =  transformPoste(seq:tag2str("#personnage4","#poste")[1])
           if table.contains(personnages[nom]["fonction"], fonction) == false 
              then
                table.insert(personnages[nom]["fonction"] , fonction  )
            end
           end

            if not personnages[nom]["paysPersonnage"]
            then
              personnages[nom]["paysPersonnage"] = country
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
          
           if (not personnages[nom]["paysPersonnage"] or ( personnages[nom]["paysPersonnage"] ~= curCountry) ) and table.contains(personnages[nom]["paysLiens"], curCountry) == false 

             then
              table.insert(personnages[nom]["paysLiens"] , curCountry  )
           end

      end


			if #seq["#revolutionPat"] ~= 0 then
      		for i = 1, #seq:tag2str("#revolutionPat") do
       			if seq:tag2str("#revolutionPat","#time")[i]~=nil	then
      			  date = seq:tag2str("#revolutionPat","#time")[i]
        		else
        			date = nil
        		end
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

      if #seq["#colonisateurPat"] ~= 0 then
				value = seq:tag2str("#colonisateurPat","#paysColonisateur")[1]

				for i = 1, #seq:tag2str("#colonisateurPat") do
        			value = seq:tag2str("#colonisateurPat","#paysColonisateur")[i]
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

      if #seq["#evenementPat"] ~= 0 then
				for i = 1, #seq:tag2str("#evenementPat") do
        			date = seq:tag2str("#evenementPat","#time")[i]
        			value = {}
        			value[1] = datePreTraite(date)
        			value[2]=seq:tag2str("#evenement")[i]
        			table.insert(pays.evenement,value)
    			end
			end


			if #seq["#independancePat"] ~= 0 then
				for i = 1, #seq:tag2str("#independancePat") do
        			date = seq:tag2str("#independancePat","#time")[i]
        			value = {}
        			value[1] = datePreTraite(date)
        			value[2]=seq:tag2str("#independancePat")[i]
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


save("dataBaseNew.txt",dbt)
save("personnagesNew.txt",personnages)

