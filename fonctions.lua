db = dofile("dataBaseNew.txt")
dbPersonnage = dofile("personnagesNew.txt")


function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function save(filename,data)
  local out = io.open(filename, "w")
  out:write("return ")
  out:write(serialize(data))
  out:close()

end

function isNumber(seq, pos)
  t={}
  for w in string.gmatch(seq[pos].token,"([^',']+)") do
    table.insert(t,w)
  end
  for i,v in ipairs(t) do
    if(string.find(v,"([a-zA-Z]+)")~=nil)then
      return false
    end
  end
  return true
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
  if myDate~=nil then
	  for w in string.gmatch(myDate, "%S+") do
    	   if w~="en" and w~="le" and w~="années" then
    		  str = str..w
    	   	str = str.." "
       	end
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

function getPersonnage(personnage)
  result = {}


    for k,elem in pairs(dbPersonnage) do
      --Boucle personnage
      --for i,elem in pairs(v) do

        if k == personnage then
          if elem["fonction"] ~= nil then
            for j, fct in pairs(elem["fonction"]) do
              table.insert(result, fct)
            end
          end

          if elem["paysPersonnage"] ~= nil then
            --print(elem["paysPersonnage"])
            return result, elem["paysPersonnage"]
          else
            --print(elem["paysLiens"][1])
            return result, elem["paysLiens"][1]
          end
        end

      --end
    end

  return result

end

function getFromPersonnage(pays, colonne)
  result = {}

      --Boucle personnage
      for i,elem in pairs(dbPersonnage) do
        --Test pour savoir si contient un paysPersonnage
        if elem[colonne] ~= nil then
            --Test pour savoir si c'est le pays recherche
            if elem[colonne] == pays then
              table.insert(result, i)
            end
        end
      end


  return result

end


-- Returns the Levenshtein distance between the two given strings
function string.levenshtein(str1, str2)
  local len1 = string.len(str1)
  local len2 = string.len(str2)
  local matrix = {}
  local cost = 0
  local max

  if len1>len2 then
    max = len1
  else
    max = len2
  end

        -- quick cut-offs to save time
  if (len1 == 0) then
    return len2
  elseif (len2 == 0) then
    return len1
  elseif (str1 == str2) then
    return 0
  end

        -- initialise the base matrix values
  for i = 0, len1, 1 do
    matrix[i] = {}
    matrix[i][0] = i
  end
  for j = 0, len2, 1 do
    matrix[0][j] = j
  end

        -- actual Levenshtein algorithm
  for i = 1, len1, 1 do
    for j = 1, len2, 1 do
      if (str1:byte(i) == str2:byte(j)) then
        cost = 0
      else
        cost = 1
      end

      matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
    end
  end

        -- return the last value - this is the Levenshtein distance
  score = matrix[len1][len2]
  -- On a change la maniere de calculer l'index de ressemblance en calculant un score maison
  return ((score*100)/max)
end

--Fonction qui evalue l'egalite de 2 chaines selon le principe de Levenshtein
function string.equals(s1, s2)
  if(string.levenshtein(s1,s2) <= 6) then
    return true
  else
    return false
  end
end

--Fonction qui permet d'insérer un element sans doublon dans une table
function table.insertOnce(my_table, value)
  for k,v in pairs(my_table) do
    if v==value then
      return;
    end
  end

  table.insert(my_table, value)
end



function getCountryFromTable(colonne, instance)

  result = {}
  if instance == nil then
    print("Désolé, "..colonne.." inconnu(e)")
    return nil
  end

  for k,v in pairs(db) do
    if(v[colonne] ~= nil) then
      for n,guerre in pairs(v[colonne]) do
        if string.equals(guerre, instance) then
          table.insertOnce(result, k)
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

  --[[for i, v in ipairs(result) do
     print(result[i], pays[i])
  end]]

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
        --print(key, val)
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



