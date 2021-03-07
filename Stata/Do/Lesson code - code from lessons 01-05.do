*Lesson 1

*Lines starting with an asterisk (*) are comments, and are not run as code

/*
Sections starting with "/*" are comments until they reach "*/"
*/

*1.5 Loading and Saving Data
use "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files\Lesson_01.dta", clear

save "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files\Lesson_01_SH.dta", replace

*1.6 Help
help save

*1.7 The Working Directory
cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"

*1.9 Importing, Exporting, Appending and Merging Data
import delimited "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files\Lesson_01.csv", clear

import delimited "Lesson_01.csv", clear

import excel "Lesson_01.xls", sheet("Sheet1") firstrow clear

use "Lesson_01_SH.dta", clear
merge 1:1 var1 using "merge.dta"

save "Lesson_01_SH.dta", replace
save "Lesson_02.dta", replace // Used to create a working copy of the dataset for lesson 2 in case of any errors

****************************************

*Lesson 2

cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"
use "Lesson_01_SH.dta", clear
*use "Lesson_02.dta", clear //Used in case of errors in the file with initials

*2.1 List
list

list age sex

set more off, permanently
*set more on, permanently

*2.2 Summarize
summarize

summarize age, detail

*2.3 Tabulate
tabulate hair_colour

tab hair_colour current_smoker

tab hair_colour current_smoker, missing

tab hair_colour current_smoker, row

tab hair_colour current_smoker, column

tab accommodation

tab accommodation, nolabel

*2.4 Generating Variables
generate average_bp = (systolic_bp+diastolic_bp)/2

gen id2 = _n 

*2.5 Replacing Variables
replace height = height/100

replace weight = weight/2.20462

gen bmi = weight/height^2
sum bmi

*2.6 Renaming Variables
rename var1 id
rename var13 marathon

*2.7 Labelling Variables

label variable hair_colour "Hair colour"
label variable average_bp "Average of systolic and diastolic blood pressure (mmHg)"
label variable id2 "ID number (2)"
label variable bmi "Body Mass Index (kg/m2)"

label variable height "Height (m)"
label variable weight "Weight (kg)"

*2.8 Labelling Values
label define marathon_label 0 "No" 1 "Yes"  
label values marathon marathon_label

label define smoker_label 1 "Yes" 2 "No"  
label values current_smoker smoker_label

tab marathon current_smoker

numlabel marathon_label smoker_label, add
tab marathon current_smoker

numlabel marathon_label smoker_label, remove
tab marathon current_smoker

label dir

label list

label drop _merge
label list

label define smoker_label 0 "Added label", add
label list

label define smoker_label 0 "Modified label", modify
label list

label define smoker_label 0 "", modify
label list

*2.9 Removing Data
drop _merge id2

save "Lesson_02_SH.dta", replace
save "Lesson_03.dta", replace // Used to create a working copy of the dataset for lesson 3 in case of any errors

keep id-weight

drop _all

clear

****************************************
*Lesson 3

cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"
use "Lesson_02_SH.dta", clear
*use "Lesson_03.dta", clear

*3.1 Restricting Commands
*The in Qualifier
list id age sex in 1/10
list id age sex in -5/-1

*3.2 Sorting a Dataset
sort age
sort hair_colour accommodation age

gsort -age
gsort -hair_colour accommodation -age

sort id

*3.3 Ordering Variables
order id age sex height weight bmi
order average_bp, before(systolic_bp)
order average_bp, after(diastolic_bp)

*3.4 Preserving Data 
preserve
order _all, alpha
restore

*3.5 The if Qualifier
sum bmi if hair_colour == "Black"
sum bmi if hair_colour != "Black"
sum bmi if hair_colour != "Black" & hair_colour != ""
*sum bmi if hair_colour != "Black" & != ""

*3.6 Missing Values
sum bmi if weight != .

replace age = . if age == 999

count if age > 60
count if age > 60 & age != .
count if age > 60 & age < .

*3.7 The if Qualifier (Continued)
sum age if (height >= 1.7 & height < . & weight < 100) | (weight < 80)
gen x = 1 if (height >= 1.7 & height < . & weight < 100) | (weight < 80)
list height weight x in 1/5
drop x

tab sex
replace sex = "Female" if sex == "female"
replace sex = "Male" if sex == "male"
tab sex

*3.8 The by Qualifier
sort hair_colour
by hair_colour: sum age

sort id
bysort hair_colour: sum age

bysort sex income: tab current_smoker
sort id

save "Lesson_03_SH.dta", replace
save "Lesson_04.dta", replace // Used to create a working copy of the dataset for lesson 4 in case of any errors

****************************************
*Lesson 4

cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"
use "Lesson_03_SH.dta", clear
*use "Lesson_04.dta", clear

*4.1 Converting String Variables to Numeric Variables (and Vice Versa)
*String Variables to Numeric Variables
destring calories, generate(calories_numeric)

destring calories, generate(calories_numeric) force

replace calories = "" if calories == "NR"
destring calories, generate(calories_numeric_2)

gen calories_numeric_3 = real(calories)
count if calories_numeric == calories_numeric_3

*Numeric Variables to String Variables
tostring(calories_numeric), gen(calories_string1)
gen calories_string2 = string(calories_numeric), a(calories_string1)

drop calories calories_numeric_* calories_string*
rename calories_numeric calories

***Precision in Stata - technical note***
gen double bmi2 = weight/height^2, a(bmi)
format bmi bmi2 %23.0g
count if bmi == bmi2
count if bmi == float(bmi2)

drop bmi2
format bmi %9.0g
*** ***

*4.2 Converting String Variables to Labelled Numeric Variables (and Vice Versa)
*String Variables to Labelled Numeric Variables
encode sex, gen(sex_numeric)
order sex_numeric, a(sex)

label list

drop sex_numeric
label drop sex_numeric
label define sex 0 "Female" 1 "Male"
encode sex, gen(sex_numeric) label(sex)
order sex_numeric, a(sex)
label variable sex_numeric "Sex 0=Female 1=Male"

tabulate sex sex_numeric, missing
tabulate sex sex_numeric, missing nolabel

encode hair_colour, gen(hair_colour_numeric)
order hair_colour_numeric, a(hair_colour)
label variable hair_colour_numeric "Hair colour"
label define income 1 "<18,000" 2 "18,000 to 30,000" 3 "30,000 to 50,000" 4 "50,000+"
encode income, gen(income_numeric) label(income)
order income_numeric, a(income)
label variable income_numeric "Income (£s)"

*Labelled Numeric Variables to String Variables
decode income_numeric, gen(income_string)
count if income_string == income

label define income 1 "<£18,000" 2 "£18,000 to £30,000" 3 "£30,000 to £50,000" 4 "£50,000+", modify

drop sex hair_colour income income_string

rename sex sex
rename hair hair_colour
rename income income

*4.3 Manipulating Strings
*split
list favourite_colours in 1/5

split favourite_colours, generate(colour_) parse(;)

label variable colour_1 "1st favourite colour"
label variable colour_2 "2nd favourite colour"
label variable colour_3 "3rd favourite colour"
order colour_*, a(favourite_colours)

*egen ends()
egen first_colour = ends(favourite_colours), punct(;) head trim
egen last_colour = ends(favourite_colours), punct(;) last trim

egen x = ends(favourite_colours), punct(;) tail trim
egen middle_colour = ends(x), punct(;) head trim

drop first_colour middle_colour last_colour x

*egen concat
egen favourite_colours_2 = concat(colour_1 colour_2 colour_3), punct(;)
count if favourite_colours == favourite_colours_2

gen favourite_colours_3 = colour_1 + ";" + colour_2 + ";" + colour_3
count if favourite_colours == favourite_colours_3

drop favourite*

*Other useful string commands
*lower(), upper(), proper()
replace colour_1 = lower(colour_1)
tab colour_1
replace colour_1 = upper(colour_1)
tab colour_1
replace colour_1 = proper(colour_1)
tab colour_1

*length()
gen x = length(colour_1)
tab x
drop x

display length("For instance, if we wanted to find out how many characters make up this sentence:")

*strpos()
gen x = strpos(colour_1,"e")
tab colour_1 x, miss
dis strpos("this is a sentence","sen")

*substr()
gen x2 = substr(colour_1,1,3)
tab x2
replace x2 = substr(colour_1,-3,3)
tab x2
replace x2 = substr(colour_1,1,x)
tab x2
drop x x2

gen x2 = substr(colour_1,1,strpos(colour_1,"e"))
tab x2
drop x2

*subinstr()
replace date_of_bp_measurement = subinstr(date_of_bp_measurement,"/","-",.)
list date_of_bp_measurement in 1/5

replace colour_2 = subinstr(colour_2," ","",.)
replace colour_3 = strtrim(colour_3)

encode colour_1, gen(colour_1x) label(colours)
encode colour_2, gen(colour_2x) label(colours)
encode colour_3, gen(colour_3x) label(colours)
order colour_1x-colour_3x, a(colour_3)
drop colour_1-colour_3
rename colour_1x colour_1
rename colour_2x colour_2
rename colour_3x colour_3

*4.4 Formatting Variables
format *

*Formatting Numeric Variables
format bmi %9.3g
list bmi in 1/5

format height %9.3g
list height in 1/5

format calories %9.3g
list calories in 1/5

format weight %12.1f
list weight in 1/5

format calories %9.2e
list calories in 1/5
format calories %9.0g

set dp comma, permanently
list height in 1/5
set dp period, permanently
list height in 1/5
format height %9,0g
list height in 1/5
format height %9.0g
list height in 1/5

format height %-9.0g
list height in 1/5
format height %9.0g

*Formatting String Variables
gen x = string(bmi,"%9.1f")
tostring bmi, gen(x2) format("%9.1f") force
gen units = "kg/m2"
egen x3 = concat(x units), punct(" ")

drop x3
egen x3 = concat(x units) if bmi < ., punct(" ")

drop x* units

*4.5 Manipulating Dates
display date("01/01/20","DMY")
display %td 21915 

display date("03-14-2013","MDY")
display %td date("03-14-2013","MDY")

display date("01 Jan 20","DMY",2000)
display %td date("01 Jan 20","DMY",2000)

gen date_of_bp_measurement_2 = date(date_of_bp_measurement,"DMY")
format date_of_bp_measurement_2 %td
label variable date_of_bp_measurement_2 "Date of blood pressure measurement"
list date_of_bp_measurement date_of_bp_measurement_2 in 1/5

gen x = string(date_of_bp_measurement_2,"%td")
list date_of_bp_measurement_2 x in 1/5
drop x

gen day = day(date_of_bp_measurement_2)
list date_of_bp_measurement_2 day in 1/5
gen month = month(date_of_bp_measurement_2)
list date_of_bp_measurement_2 month in 1/5
gen year = year(date_of_bp_measurement_2)
list date_of_bp_measurement_2 year in 1/5
drop day month year

drop date_of_bp_measurement
rename date_of_bp_measurement_2 date_of_bp_measurement

save "Lesson_04_SH.dta", replace
save "Lesson_05.dta", replace // Used to create a working copy of the dataset for lesson 5 in case of any errors

*********************************************************

*Lesson 5

cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"
use "Lesson_04_SH.dta", clear
*use "Lesson_05.dta", clear

*5.1 Macros
*local macros
local a = 3
display `a'
macro list

macro drop _a
macro list

local number = 5
dis `number' * 10 + 2
local list_of_numbers 1 2 3 4 5
dis `list_of_numbers'*2

local expression = 5*10+2
dis `expression'

local string This is a string
dis "`string'"
local string "This is also a string"
dis "`string'"
local string "This is also a string, but strings need quotes"
*dis `string'
local string "String 1" "String 2" "String 3"
dis "`string'"

local variables id age sex bmi calories
sum `variables'

local macro_1 = 5
local macro_2 = 10
local macro_3 = 2
local macro_4 = `macro_1' * `macro_2' + `macro_3'
dis `macro_4'

local age_1 = age[1]
dis `age_1'
list age in 1

*global macros
global a = 3
dis $a

*5.2 Stored Results
*return list
sum bmi
return list

dis r(N)

local N = r(N)
local mean = r(mean)
dis "The number of observations is `N', the mean is "string(`mean',"%9.2f")

qui sum bmi
local mean = r(mean)
local sd = r(sd)
gen bmi_norm = (bmi-`mean')/`sd', a(bmi)
sum bmi_norm
label variable bmi_norm "Body mass index (normalised)"

sum age, detail
return list

tab hair_colour
return list

*ereturn list
regress bmi age
ereturn list 

matrix list e(b)
matrix list e(V)

dis 0.0062816^2

save "Lesson_05_SH.dta", replace  

******************************************************
