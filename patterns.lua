dark = require("dark")


tags = {
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
	["#personnage3"] ="blue",
	["#evenement"] = "red",
	["#colonisateur"] = "white",
	["#gentiles"] = "green"
}

pipe = dark.pipeline()
pipe:basic()

pipe = dark.pipeline()
pipe:basic()


pipe:model("../model-2.3.0/postag-fr")
pipe:lexicon("#nomPays", "lex/nomPays.txt")
pipe:lexicon("#paysColonisateur", "lex/nomPaysAdjectif.txt")
pipe:lexicon("#gentiles", "lex/gentiles.txt")
pipe:lexicon("#prenom", "lex/prenoms.txt")
pipe:lexicon("#personne", "lex/personnages.txt")
pipe:lexicon("#continentName", {"Afrique", "Amérique", "Asie", "Europe", "Océanie"})
pipe:lexicon("#mois", {"janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"})
pipe:lexicon("#pointsCardinaux", {"nord", "sud", "ouest", "est"})
pipe:lexicon("#ocean", {"océan Pacifique", "océan Atlantique", "océan Indien", "océan Arctique"})
pipe:lexicon("#colonie",{"colonie","colonisateur","colonialisme","colonisation","colonial","coloniale"})
pipe:lexicon("#articleIndefini",{"du","de la ","de","des"})
pipe:lexicon("#poste",{"roi","duc","grand duc","reine","prince","sénateur","député","président de la république ","président de la République ","secrétaire général","président","premier ministre","Premier ministre","ministre","chef du gouvernement","général","empereur"})




pipe:model("../model-2.3.0/postag-fr")
pipe:lexicon("#capitale", {"capitale"})
pipe:lexicon("#paysFrontaliers", {"pays frontaliers","pay frontalier","pays frontalier","pay frontaliers", "pays limitrophes"})
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
pipe:lexicon("#min", {"la plus petite", "le plus petit", "la moins grande", "le moins grand"})
pipe:lexicon("#max", {"la moins petite", "le moins petit", "la plus grande", "le plus grand"})


pipe:lexicon("#pronomInterrogatifPersonne", {"Qui","qui"})
pipe:lexicon("#pronomInterrogatifBinaire", {"est ce que", "Est ce que", "est-ce-que", "Est-ce-que"})
pipe:lexicon("#pronomInterrogatifDate", {"Quand", "quand"})
pipe:lexicon("#pronomInterrogatifLieu", {"Où", "où", "Ou", "ou"})
pipe:lexicon("#pronomInterrogatifGeneralSing", {"Quel", "quel", "Quelle", "quelle"})
pipe:lexicon("#pronomInterrogatifGeneralPlu", {"Quels", "quels", "Quelles", "quelles" })
pipe:lexicon("#pronomInterrogatifChoix", {"Lequel", "Laquelle", "lequel", "laquelle"})
pipe:lexicon("#pronomInterrogatifHistoire", {"Qu'est ce qui", "Qu'est-ce-qui","qu'est ce qui", "qu'est-ce-qui"})
pipe:lexicon("#champsDetecter",{"guerre","superficie","revolution","autreNoms","l'autreNoms","capitale","indépendance","l'indépendance","evenement","l'evenement","population","langue","colonisateur","paysFrontaliers","personnage"})
pipe:lexicon("#pronomInterrogatifComplexe",{"Et celle", "Celle", "Et celui", "et celle", "et celui", "Celui", "celui", "celle", "Et ceux", "et ceux", "Et celles", "et celles", "Et", "et"})
pipe:lexicon("#pronomInterrogatifPays", {"Quel", "quel", "Quelle", "quelle", "Quels", "quels", "Quelles", "quelles"})


-- Pattern pour détecter une personne en utilisant le lexique des prénoms
pipe:pattern([[
	[#personne
		#prenom [#nom ( /^%u/ /^%u/ | /^%u/) ]
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
	[#autreNomsPat
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
	[#continentPat
    ("est" "un" "pays" "d" "'" #continentName) |
    (#nomPays {0,20}?  "pays" {0,10} #continentName )
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
	[#capitalePat
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
----#POS=ADJ| #POS=NNC)
pipe:pattern([[
	[#languePat
    "langue" ("officielle" | "nationale" | "principale") (("du" | "de" "la" | "des") #nomPays)?
    ("est" | ",")? ("le" | "l" "'" | "la")? ([#name  #gentiles])
    |
    [#name  #gentiles] ("est" | "étant" "proclamé")? ("la")? "langue" ("officielle" | "nationale")
	]
]])


-- Pattern pour détecter la monnaie utilisée dans un pays
pipe:pattern([[
	[#monnaiePat
    "monnaie" ("officielle" | "nationale")? ("est"| "était" | ",")? [#name ("le" | "l" "'" | "la") (/^%l/ /^%l/ "-" /^%l/ |/^%l/ /^%l/ | /^%l/)?]
    |
    [#name ("le" | "Le" | "La" | "l" "'" | "L" "'" | "la") (/^%l/ /^%l/ | /^%l/)?] ("est" | "était") ("adopté" "comme" | "resté"| "déjà")? ("sa" | "la")? "monnaie"
	]
]])


-- Pattern pour détecter la population habitant d'un pays
pipe:pattern([[
	[#populationPat
    [#nombre  #number "millions"]  ("habitants" | "d" "'" "habitants")
    |
    [#nombre  #number]  ("habitants" | "d" "'" "habitants")
    |
    [#nombre  @isNumber "millions"]  ("habitants" | "d" "'" "habitants")
	]
]])


-- Pattern pour détecter la superficie d'un pays
pipe:pattern([[
	[#superficiePat
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
  [#paysFrontaliersPat
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
	   		(#poste #articleIndefini  #nomPays .{0,8}?   #personne	)
	   		(#personne  .{0,8}?  "élu" #poste .{0,8}? #nomPays )

	  ]
]])

-- Pattern pour détecter les personnages (fonction en rapport à une personne)
pipe:pattern([[
	  [#personnage4
	   		(#personne .{0,5}? ("élu"|"élue"|"réélu"|"réélue") {0,3}? #poste  )

	  ]
]])


-- Pattern pour détecter les personnages (fonction en rapport à une personne)
pipe:pattern([[
	  [#personnage2
	   		(#poste .{0,5}? #personne ) | (#personne .{0,5}? #poste )
	  ]
]])


-- Pattern pour détecter les révolutions ayant eu lieu et la date
pipe:pattern([[
  [#revolutionPat
  	@NotPoint*? [#time ("le" #date)|(("en"|"années") #number)] .*? ("révolution" | "Révolution"|"révolte"|"Révolte").*? ("." | $ | "!" | "?")
  	|
  	@NotPoint*? ("révolution" | "Révolution"|"révolte"|"Révolte") .*? [#time ("le" #date)|(("en"|"années") #number)] .*? ("." | $ | "!" | "?")
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

--[[
pipe:pattern([[
	[#evenementPat
		@NotPoint*? [#time ("le" #date)|(("en"|"années") #number)] .*? ("." | $ | "!" | "?")
	]
]]


-- Pattern pour détecter un colonisateur en rapport à un évènement d'indépendance
pipe:pattern([[
	[#colonisateurPat
		(#colonie .*? (#paysColonisateur)+)
		|
		((#paysColonisateur).*?#colonie)
		|
		("contre" .*? (#paysColonisateur)+)
	]
]])


-- Pattern pour détecter une date d'indépendance
pipe:pattern([[
	[#independancePat
		(
			@NotPoint*?
			(
				("un" ("État"|"état") "indépendant")
				|"fondation" [#pays (("le" | "la" | "l" "'") #nomPays)]
				|("devient"|"est"|"soit"|"était") ("indépendante"|"independant")
				|(("l" "'")|"son") "indépendance"
				|"à" "la" "pleine" "souveraineté"
			)
			@NotPoint*?[#time ("le" #date)|(("en"|"années") #number)].*? ("." | $ | "!" | "?")
		)
		|
		(
			@NotPoint*?[#time ("le" #date)|(("en"|"années") #number)]@NotPoint*?
			(
				"un" ("État"|"état") "indépendant"
				|"fondation" [#pays (("du" | "de" "la" | "des"| "de" "l" "'") #nomPays)]
				|("devient"|"est"|"soit"|"était") ("indépendante"|"independant")
				|(("l" "'")|"son") "indépendance"
				|"à" "la" "pleine" "souveraineté"
			).*? ("." | $ | "!" | "?")
		)
	]
]])





pipe:pattern([[
  [#question
    ((#pronomInterrogatifPersonne | #pronomInterrogatifDate | #pronomInterrogatifLieu | #pronomInterrogatifGeneralSing
      | #pronomInterrogatifGeneralPlu)) ("est" | "sont") (/./)*
  ]
]])


pipe:pattern([[
  [#questionPays
  (
   [#infoName ("Le"| "La" | "le" | "la" | "l" "'" | "L" "'")?  (/^%u/ /^%u/ | /^%u/ | /^%l/ /^%l/ | /^%l/ )] ("est")? .* (#pronomInterrogatifGeneralSing| #pronomInterrogatifGeneralPlu) "pays"
  )
  |
  (
   (#pronomInterrogatifGeneralSing | #pronomInterrogatifGeneralPlu) ("est" | "sont")? ("le" | "les")? "pays" .* ("est" | )  [#infoName ("Le"| "La" | "le" | "la" | "l" "'" | "L" "'")?  (/^%u/ /^%u/ | /^%u/ | /^%l/ /^%l/ | /^%l/ )]
  )
  |
  (
   (#pronomInterrogatifGeneralSing | #pronomInterrogatifGeneralPlu) ("est" | "sont")? ("le" | "les")? "pays" .* [#infoName ("Le"| "La" | "le" | "la" | "l" "'" | "L" "'")?  (/^%u/ /^%u/ | /^%u/ | /^%l/ /^%l/ | /^%l/ )] ("pour" | "comme") (/./)*
  )
  ]
]])


pipe:pattern([[
  [#questionBinaire
    #pronomInterrogatifBinaire [#info1 (/./)*] ("est" | "sont") [#info2 (/./)*]
  ]
]])

pipe:pattern([[
  [#questionBinaire2
    #pronomInterrogatifBinaire2 (/./)* [#periode ("en" [#annee1 #d] | "entre" [#annee2 #d] "et" [#annee3 #d] | "après" [#annee4 #d] | "avant" [#annee5 #d])]
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


pipe:pattern([[
	[#questionComplexe
	  (
    (#pronomInterrogatifGeneralSing | #pronomInterrogatifGeneralPlu) ("est" | "sont")
    ("celui" | "ceux" | "celle" | "celles") ("de" "la" | "du" | "de" "l" "'") #nomPays
    )
    |
    (
    #pronomInterrogatifComplexe ("de" "la" | "du" | "de" "l" "'") #nomPays
    )
  ]
]])


