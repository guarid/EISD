db = dofile("dataBase.txt")


function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end


function transformPoste(poste)
	if poste =="président"
	  then
	  	poste = poste.." de la République"
	  end

	  return poste
	end



function NotPoint(seq, pos)
	return (seq[pos].token ~= "." and seq[pos].token ~= "!" and seq[pos].token ~= "?" and seq[pos].token ~= "^")
end



function datePreTraite(myDate)
	t = {}
	str = ""
	for w in string.gmatch(myDate, "%S+") do
    	if w~="en" and w~="le" and w~="années" then
    		str = str..w
    		str = str.." "
    	end
	end
	return str

end




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



