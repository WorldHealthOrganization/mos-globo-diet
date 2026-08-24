OPTION LINESIZE=256 PAGESIZE=1000 COMPRESS=BINARY NOCENTER ;
LIBNAME A       '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses';
LIBNAME library '\\inti\nme\DEX\Global Surveillance\Data_Analyses\Malta\Malta-FinalAnalyses\SASprog_FinalAnalyses';

Proc format library=a ;

* For Intgi;

  Value Dayoweek
    1 = "Monday"
    2 = "Tuesday"
    3 = "Wednesday"
    4 = "Thursday"
    5 = "Friday"
    6 = "Saturday"
    7 = "Sunday" ;

  Value $Country
   'AT_' = 'Austria'
   'BE_' = 'Belgium'
   'BG_' = 'Bulgaria'
   'BR_' = 'Brazil'
   'CH_' = 'Switzerland'
   'CZ_' = 'Czech Republic'
   'DE_' = 'Germany'
   'DK_' = 'Denmark'
   'ES_' = 'Spain'
   'FI_' = 'Finland'
   'FR_' = 'France'
   'GB_' = 'United Kingdom'
   'GR_' = 'Greece'
   'HU_' = 'Hungary'
   'IT_' = 'Italy'
   'KR_' = 'Republic of Korea'
   'MX_' = 'Mexico'
   'NL_' = 'The Netherlands'
   'NO_' = 'Norway'
   'PL_' = 'Poland'
   'SE_' = 'Sweden'
   'PT_' = 'Portugal';

  Value $Gender
   '1' = "Man"
   '2' = "Woman" ;

  Value agec
  	1 = "<18 years old"
	2 = "18-51 years old"
	3 = " More than 51";

  Value fagegr
 	1 = "<11 years old"
 	2 = "11-17 years old"
 	3 = "18-30 years old"
 	4 = "31-51 years old"
 	5 = "52-64 years old"
	6 = "More than 64";

  ** to be adpated according to the Country selection ;
  Value $Spdiet
   '00' = 'None'
   '01' = 'Energy restricted (doctor’s order)'
   '02' = 'Energy restricted (own initiative)'
   '03' = 'Fat and/or cholesterol restricted'
   '04' = 'Protein restricted'
   '05' = 'Sodium restricted (e.g. hypertension)'
   '06' = 'Diabetes'
   '07' = 'Easy digestible (e.g. stomach/bowel disease)'
   '08' = 'Dietary fiber enriched'
   '09' = 'Food Allergy: cow’s milk protein free'
   '10' = 'Food Allergy: chicken egg protein free'
   '11' = 'Gluten free'
   '12' = 'Lactose restricted'
   '13' = 'Other food intolerance/allergy'
   '14' = 'Vegetarian: no meat/no fish'
   '15' = 'Little meat (less than once a week)'
   '16' = 'No meat/with fish'
   '17' = 'Veganism: no animal products at all'
   '18' = 'Macrobiotic'
   '19' = 'Antroposofic'
   '20' = 'Islamic diet'
   '21' = 'Jewish diet'
   '22' = 'During pregnancy'
   '23' = 'During breast feeding'
   '24' = 'High protein diet'
   '25' = 'Low carbohydrate diet'
   '26' = 'Diet linked to religion (halal, casher…)'
   '27' = 'Food allergy : peanut protein free'
   '28' = 'Other food intolerance'
   '29' = 'Other food allergy'
   '30' = 'Energy and/or protein enriched'
   '31' = 'Food allergy: soya protein free'
   '33' = 'Food allergy/intolerance n.s.'
   '34' = 'Vegetarian or veganism (no meat, no fish)' 
   '99' = 'Other';

  ** to be adpated according to the Country selection ;
  Value $Spday
   '00' = 'None'
   '01' = 'Feast-day (religious holiday/celebration)'
   '02' = 'Celebration meals (birthday, wedding, communion,...)'
   '03' = 'Travel/On trip'
   '04' = 'Illness/Tiredness'
   '05' = 'Holidays/Vacations'
   '06' = 'Fasting day (including religious)'
   '07' = 'Extreme weather conditions (very hot/cold)'
   '08' = 'Very busy/Away from home a lot'
   '09' = 'Night work'
   '99' = 'Other'
   /* when multi-selections are available, you can add them */
   '01,03' = 'Feast-day & Travel/On trip '
   '01,05' = 'Feast-day & Illness/Tiredness'
   '03,05' = 'Travel/On trip & Holidays/Vacations'
   '03,99' = 'Travel/On trip & Other'
   '04,08' = 'Illness/Tiredness & Very busy/Away from home a lot'
   '07,99' = 'Extreme weather conditions & Other'
   '08,99' = 'Very busy/Away from home a lot & Other' ;


 * For interv & interv_qt;

  Value $Type
   '1'  = "FCO"
   '2'  = "QLI"
   '3'  = "Recipe"
   '4'  = "Food"
   '5'  = "Recipe Ingredient"
   '6'  = "Fat during cooking for food"
   '7'  = "Fat during cooking for ingredient"
   '8'  = "Fat/Sauce/Sweeteners -> to be deleted"
   '9'  = "Dietary supplement"
   'A2' = "Fat used facet" 
   'A3' = "Milk/liquid used facet" 
   '2S' = "QLI for dietary supplement"
   '3S' = "Recipe selected as a recipe ingredient: Sub-recipe"
   '5S' = "Food selected as a sub-recipe Ingredient";

  Value $FCO
   '01' = 'Before Breakfast (Wake Up)'
   '02' = 'Breakfast'
   '03' = 'During the Morning'
   '04' = 'Before Lunch (Aperitif)'
   '05' = 'Lunch'
   '06' = 'After Lunch'
   '07' = 'During Afternoon'
   '08' = 'Before Dinner (Aperitif)'
   '09' = 'Evening meal'
   '10' = 'After Dinner (Digestif)'
   '11' = 'During the Evening / At Night' ;

  Value $POC
  '01' = 'Home'
  '02' = 'Work (no catering)'
  '03' = 'School/Child care'
  '04' = 'Friends/Family'
  '05' = 'Sport accommodation'
  '06' = 'Restaurant etc'
  '07' = 'Fast food restaurant'
  '08' = 'Cafe/Bar/Coffee shop/Pub'
  '10' = 'Outside (Street/Market/Park/Beach)'
  '11' = 'Travelling (Bicycle/Car/Boat/Plane)'
  '12' = 'Workplace/school'
  '13' = 'Other restaurant/hotel'
  '14' = 'Nursing home restaurant'
  '15' = 'Restaurant/café/fast food n.s. '
  '16' = 'Other inside place'
  '99' = 'Other' ;

  Value $Qmethod
    'G' = "Gram"
    'V' = "Volume"
    'P' = "Photo"
    'H' = "HHM"
    'U' = "Std Unit"
    'S' = "Std Portion"
    'A' = "Shape"
    'W' = "Whole recipe fraction"
    '%' = "Fat percentage"
    '?' = "Unknown Qty";

  Value $Ftype
   'GI' = "Generic Item"
   'SH' = "Shadow"
   '0'  = "Non Generic Item" ;

  Value $Rtype
    '1.1' = "Open – Known"
    '1.2' = "Open – Unknown"
    '1.3' = "Open with brand"
    '2.1' = "Closed"
    '2.2' = "Closed with brand" 
    '3.0' = "Strictly commercial"
    '4.1' = "New – Known"	
    '4.2' = "New – Unknown" ;

  Value $Itype
    '1'  = "Fixed"
    '2'  = "Substituted"
    '3'  = "Fat during cooking"
    'A2' = "Fat used facet" 
	'A3' = "Milk/liquid used facet" ;

  Value Rmod
    0 = "No modification"
    1 = "Modified in New int. mode - No update needed" 
    2 = "Modified in New int. mode – Update needed"
    3 = "Modified in Edit int. mode(previouly R_Modif=0)"
    4 = "Modified in Edit int. mode(previouly R_Modif=1)"
    5 = "Modified in Edit int. mode(previouly R_Modif=2)" ;

  Value Imod
    0 = "No modification"
    1 = "Added in New int. mode"
    2 = "Deleted in New int. mode(ingr. cons_qty>5%)"
    3 = "Substituted in New int. mode"
    4 = "Added in Edit int. mode"
    5 = "Substituted in Edit int. mode" ;

  Value $Status
    '0' = "not described/quantified"
    '1' = "described & quantified"
    '2' = "not quantified" ;

  Value $Rcook
    '1' = "Raw"
    '2' = "Cooked/Not Applic" ;

  Value $Edib
    '1' = "Without inedible/Not Applic"
    '2' = "With inedible" ;

  Value YN
    0 = 'No' 
    1 = 'Yes' ;

  Value $Grp
    '00' = "UNCLASSIFIED"
    '01' = "POTATOES AND OTHER TUBERS"
    '02' = "VEGETABLES"
    '03' = "LEGUMES"
    '04' = "FRUITS, NUTS AND SEEDS, OLIVES"
    '05' = "DAIRY PRODUCTS AND SUBSTITUTES"
    '06' = "CEREALS AND CEREAL PRODUCTS"
    '07' = "MEAT, MEAT PRODUCTS AND SUBSTITUTES"
    '08' = "FISH, SHELLFISH AND AMPHIBIANS"
    '09' = "EGGS AND EGG PRODUCTS"
    '10' = "FATS AND OILS"
    '11' = "SUGAR AND CONFECTIONERY"
    '12' = "CAKES AND SWEET BISCUITS"
    '13' = "NON ALCOHOLIC BEVERAGES"
    '14' = "ALCOHOLIC BEVERAGES"
    '15' = "CONDIMENTS, SPICES, SAUCES AND YEAST"
    '16' = "SOUPS AND STOCKS"
    '17' = "MISCELLANEOUS"
    '18' = "SAVOURY SNACKS" ;

  Value $Fclas 
    '00'     = "UNCLASSIFIED"
    '01'     = "POTATOES AND OTHER TUBERS"
    '0100'   = "UNCLASSIFIED, MIXED AND OTHER TUBERS"
    '0101'   = "POTATOES"
    '02'     = "VEGETABLES"
    '0200'   = "UNCLASSIFIED, MIXED SALAD/VEGETABLES"
    '0201'   = "LEAFY VEGETABLES (EXCEPT CABBAGES)"
    '0202'   = "FRUITING VEGETABLES"
    '0203'   = "ROOT VEGETABLES"
    '0204'   = "CABBAGES"
    '0205'   = "MUSHROOMS"
    '0206'   = "GRAIN AND POD VEGETABLES"
    '0207'   = "LEEK, ONION, GARLIC"
    '0208'   = "STALK VEGETABLES, SPROUTS"
    '0209'   = "FLOWERS"
    '03'     = "LEGUMES"
    '0300'   = "UNCLASSIFIED"
    '0301'   = "LEGUMES"
    '04'     = "FRUITS, NUTS AND SEEDS, OLIVES"
    '0400'   = "UNCLASSIFIED, MIXED FRUITS, NUTS AND SEEDS"
    '0401'   = "FRUITS"
    '040100'   = "UNCLASSIFIED, MIXED FRUITS, FRUIT COMPOTE "
    '040101'   = "FRUITS "
    '040102'   = "FRUIT COMPOTE "
    '0402'   = "NUTS AND SEEDS (INCLUDING NUT SPREAD)"
    '040200'   = "UNCLASSIFIED NUTS AND SEEDS (+ NUT SPREAD)"
    '040201'   = "NUTS, SEEDS "
    '040202'   = "PEANUT BUTTER, NUT/SEEDS SPREAD "
    '0403'   = "OLIVES"
    '05'     = "DAIRY PRODUCTS AND SUBSTITUTES"
    '0500'   = "UNCLASSIFIED AND MIXED DAIRY PRODUCTS"
    '0501'   = "MILK, MILK BEVERAGES AND FERMENTED MILK BEVERAGES"
    '050100' = "UNCLASSIFIED OR COMBINED MILK AND MILK BEVERAGES"
    '050101' = "NON FERMENTED MILK AND MILK BEVERAGES"
    '050102' = "FERMENTED MILK, MILK BEVERAGES AND YOGHURT DRINKS"
    '0502'   = "MILK SUBSTITUTES AND MILK SUBSTITUTE PRODUCTS"
    '0503'   = "YOGHURT"
    '0504'   = "FROMAGE BLANC, PETITS SUISSES"
    '0505'   = "CHEESES (INCLUDING SPREAD CHEESES)"
    '0506'   = "CREAM DESSERTS, PUDDINGS (MILK BASED)"
    '0507'   = "DAIRY AND NON DAIRY CREAMS, CREAMERS"
    '050700' = "UNCLASSIFIED CREAMS"
    '050701' = "DAIRY CREAMS AND CREAMERS"
    '050702' = "NON DAIRY CREAMS AND CREAMERS"
    '0508'   = "ICE CREAM AND SUBSTITUTES, SORBET AND WATER ICE"
    '050800' = "UNCLASSIFIED, COMBINED ICE CREAMS/SORBETS"
    '050801' = "ICE CREAM (MILK BASED)"
    '050802' = "ICE CREAM SUBSTITUTES"
    '050803' = "SORBET/WATER ICE"
    '06'     = "CEREALS AND CEREAL PRODUCTS"
    '0600'   = "UNCLASSIFIED AND COMBINED CEREAL PRODUCTS"
    '0601'   = "FLOURS, STARCHES, FLAKES, SEMOLINA USED AS FLOUR"
    '0602'   = "PASTA, RICE, OTHER GRAIN"
    '0603'   = "BREAD, CRISPBREAD, RUSKS"
    '060300' = "UNCLASSIFIED OR MIXED BREADS AND RUSKS"
    '060301' = "BREAD"
    '060302' = "CRISPBREAD, RUSKS"
    '0604'   = "BREAKFAST CEREALS"
    '0605'   = "DOUGH AND PASTRY (PLAIN PUFF, SHORT-CRUST, PIZZA)"
    '07'     = "MEAT, MEAT PRODUCTS AND SUBSTITUTES"
    '0700'   = "UNCLASSIFIED AND COMBINED MEAT AND MEAT PRODUCTS"
    '0701'   = "DOMESTIC MAMMALS"
    '070100' = "UNCLASSIFIED, MIXED AND OTHER MAMMALS"
    '070101' = "BEEF"
    '070102' = "VEAL"
    '070103' = "PORK"
    '070104' = "MUTTON/LAMB"
    '070105' = "HORSE"
    '070106' = "GOAT"
    '070107' = "RABBIT"
    '0702'   = "POULTRY"
    '070200' = "UNCLASSIFIED AND OTHER POULTRY"
    '070201' = "CHICKEN, HEN"
    '070202' = "TURKEY, YOUNG TURKEY"
    '070203' = "DUCK"
    '070204' = "GOOSE"
    '0703'   = "GAME"
    '0704'   = "PROCESSED MEAT"
    '0705'   = "OFFALS"
    '0706'   = "MEAT SUBSTITUTES"
    '08'     = "FISH, SHELLFISH AND AMPHIBIANS"
    '0800'   = "UNCLASSIFIED AND COMBINED FISH PRODUCTS"
    '0801'   = "FISH"
    '0802'   = "CRUSTACEANS, MOLLUSCS"
    '0803'   = "FISH PRODUCTS, FISH IN CRUMBS"
    '0804'   = "AMPHIBIANS AND REPTILES"
    '09'     = "EGGS AND EGG PRODUCTS"
    '0900'   = "UNCLASSIFIED EGGS AND EGG PRODUCTS"
    '0901'   = "EGGS"
    '10'     = "FATS AND OILS"
    '1000'   = "UNCLASSIFIED AND COMBINED FATS"
    '1001'   = "VEGETABLE OILS"
    '1002'   = "BUTTER"
    '1003'   = "MARGARINES AND COOKING FATS"
    '1004'   = "OTHER ANIMAL FATS (INCLUDING FISH OILS)"
    '11'     = "SUGAR AND CONFECTIONERY"
    '1100'   = "UNCLASSIFIED OR COMBINED CONFECTIONERY ITEMS"
    '1101'   = "SUGAR, HONEY, JAM, SYRUP, SWEET SAUCE"
    '110100' = "UNCLASSIFIED AND OTHER SUGAR, HONEY, JAM, SYRUP, SWEET SAUCE"
    '110101' = "SUGAR"
    '110102' = "JAM, JELLY, MARMELADE"
    '110103' = "HONEY"
    '110104' = "OTHER SWEET SPREAD"
    '110105' = "SWEET SAUCE, SWEET TOPPING FOR DESSERTS"
    '110106' = "SYRUP (INCL. FROM CAN AND FOR BEVERAGES)"
    '1102'   = "CHOCOLATE, CANDY BARS, PASTE, CONFETTI/FLAKES"
    '110200' = "UNCLASSIFIED AND OTHER CHOCOLATE CONFECTIONERY (INCL. SAUCE)"
    '110201' = "CHOCOLATE TABLET"
    '110202' = "CHOCOLATE CANDY BARS"
    '110203' = "CHOCOLATE SPREAD AND CHOCOLATE POWDER"
    '110204' = "CHOCOLATE CONFECTIONERY"
    '1103'   = "CONFECTIONERY NON CHOCOLATE"
    '12'     = "CAKES AND SWEET BISCUITS"
    '1200'   = "UNCLASSIFIED AND COMBINED CAKES, BISCUITS"
    '1201'   = "CAKES, PIES, PASTRIES, PUDDINGS (NON MILK BASED)"
    '1202'   = "DRY CAKES, SWEET BISCUITS"
    '13'     = "NON ALCOHOLIC BEVERAGES"
    '1300'   = "UNCLASSIFIED AND COMBINED NON ALC. DRINKS"
    '1301'   = "FRUIT AND VEGETABLE JUICES"
    '1302'   = "CARBONATED/SOFT/ISOTONIC DRINKS, DILUTED SYRUPS"
    '1303'   = "COFFEE, TEA AND HERBAL TEAS"
    '130300' = "UNCLASSIFIED AND COMBINED COFFEE/TEA DRINKS"
    '130301' = "COFFEE"
    '130302' = "TEA"
    '130303' = "HERBAL TEA"
    '130304' = "CHICORY, SUBSTITUTES"
    '1304'   = "WATERS"
    '14'     = "ALCOHOLIC BEVERAGES"
    '1400'   = "UNCLASSIFIED, COCKTAILS, PUNCHES"
    '1401'   = "WINE, CIDER, FRUIT WINES"
    '1402'   = "FORTIFIED WINES (SHERRY,PORTO,VERMOUTH,..)"
    '1403'   = "BEER"
    '1404'   = "SPIRITS, BRANDY"
    '1405'   = "ANISEED DRINKS (PASTIS,..)"
    '1406'   = "LIQUEURS"
    '15'     = "CONDIMENTS, SPICES, SAUCES AND YEAST"
    '1500'   = "UNCLASSIFIED OR COMBINED CONDIMENTS AND SAUCES"
    '1501'   = "SAVOURY SAUCES"
    '150100' = "OTHER AND MIXED SAUCES"
    '150101' = "TOMATO SAUCES"
    '150102' = "DRESSING SAUCES, MAYONNAISES AND SIMILAR"
    '150103' = "MAYONNAISE BASED SPREADS"
    '1502'   = "YEAST"
    '1503'   = "SPICES, HERBS AND FLAVOURINGS"
    '1504'   = "CONDIMENTS"
    '16'     = "SOUPS AND STOCKS"
    '1600'   = "UNCLASSIFIED OR COMBINED SOUPS AND STOCKS"
    '1601'   = "SOUPS"
    '1602'   = "STOCKS"
    '17'     = "MISCELLANEOUS"
    '1700'   = "UNCLASSIFIED OR COMBINED MISCELLANEOUS FOODS"
    '1701'   = "VEGETARIAN PRODUCTS/DISHES"
    '1702'   = "DIETETIC PRODUCTS"
    '170200' = "UNCLASSIFIED AND COMBINED DIETETIC PRODUCTS"
    '170201' = "ARTIFICIAL SWEETENERS"
    '170202' = "MEAL SUBSTITUTES"
    '1703'   = "INSECTS"
    '18'     = "SAVOURY SNACKS"
    '1800'   = "UNCLASSIFIED OR COMBINED SNACKS"
    '1801'   = "SAVOURY SNACKS, BISCUITS AND CRISPS"
    '1802'   = "SAVOURY FILLED BUNS, CROISSANTS" ;


* For Intnut ;

    Value NTRCODE

    1 = 'Energy'
    2 = 'Total proteins'
    3 = 'Carbohydrates'
    4 = 'Total fats'
    5 = 'Alcohol'
    6 = 'Water';

* For Note ;

    Value $NTYPE
    'G'     = 'General'
    'G_DT'  = 'Other special diet'
    'G_DY'  = 'Other special day'
    'SPE'   = 'Specific note attached record item'
    'EMP'   = 'Empty FCO or Quick list item'
    'UNK'   = 'Unknown quantity'	
    'NULL'  = 'Null quantity'
    'OVER'  = 'Overflow quantity'
    'NEW_F' = 'New food/Ingredient'	
    'NEW_R' = 'New recipe'
    'NEW_C' = 'New Commercial recipe'
    'COM'   = 'Commercial recipe'	
    'I_ADD' = 'Added (ingredient)'	
    'I_DEL' = 'Deleted (ingredient'
    'F_01'  = 'Reported Other Source attached to supplement'
    'F_02'  = 'Reported Other Target group attached to supplement'	
    'F_03'  = 'Reported Other Place of acquisition attached to supplement'
    'F_04'  = 'Reported Other Packaging attached to supplement' ;

  ** to be adapted according to the Country selection ;
	Value $NSTATUS
    '00' = 'New'
    '01' = 'Ongoing'
    '02' = 'No action needed'
    '03' = 'Action approved by coordinator'
    '04' = 'To be discussed'
    '05' = 'To be verified (packaging)'
    '06' = 'Action after GloboDiet DB update' 
    '07' = 'Missing: to be filled later'
    '08' = ' Supplement to be identified'
    '99' = 'Action done'
    '999'= 'Deleted';

Value Seasonsa
    1 = "Spring/Summer"
    2 = "Automn/Winter" ;

Value Seasonsb
    1 = "Spring"
    2 = "Summer"
    3 = "Automn"
    4 = "Winter" ;

Value DayCL
    1 = "Monday -> Thursday"
    2 = "Friday -> Sunday" ;


RUN;



