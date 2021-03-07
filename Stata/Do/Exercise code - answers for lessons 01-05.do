*Exercise 01

cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"

use "Exercise_01.dta", clear

save "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Exercise_01_SH.dta", replace

append using "Exercise_01_append.dta"

merge 1:1 id using "Exercise_01_merge.dta"

help merge

save "Exercise_01_SH.dta", replace
export excel using "Exercise_01_SH", firstrow(variables) replace

save "Exercise_02.dta", replace // Used to create a working copy of the dataset for exercise 2 in case of any errors

****************************************************

*Exercise 02

*1
cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"
use "Exercise_01_SH.dta", clear
*use "Exercise_02.dta", clear //if you’re not confident in your save from the last exercise

*2
list age height

*3
summarize height, detail //*There are values of -1 for height, which definitely seems wrong

*4
tab hair_colour //141 people have red hair

*5
tab hair_colour accommodation, row // 48.36% of people with black hair rent

*6
tab hair_colour accommodation, col // 12.06% of people who own their home have grey hair

*7
label list //The hair_colour and accommodation labels are called the same as the variables: hair_colour and accommodation
numlabel hair_colour accommodation, add
tab hair_colour accommodation

*8
label define hair_colour 3 "Blonde", modify
label list //The "Blonde" label doesn't have a number prefix, while the others do
numlabel hair_colour, add force //This forces the labels without prefixes to get one
*OR*
label define hair_colour 3 "3. Blonde", modify //This also works, directly modifying the label to have the prefix

*9
replace age = age/12
replace weight = weight*6.35

*10
gen bmi = weight/height^2
label variable bmi "Body mass index (kg/m2)"
sum bmi, detail //some values are very high (>100). This is likely due to the "-1" values of height

*11
label define income 1 "<£18,000" 2 "£18,000 to £30,000" 3 "£30,000 to £50,000" 4 "£50,000+"
label values income income
tab income

*12
rename var3 sex
rename var14 smoking_status //or current_smoker, or anything really so long as it makes sense

*13
drop _merge

save "Exercise_02_SH.dta", replace
save "Exercise_03.dta", replace // Used to create a working copy of the dataset for exercise 3 in case of any errors

****************************************************

*Exercise 03

*1
cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"
use "Exercise_02_SH.dta", clear
*use "Exercise_03.dta", clear //if you’re not confident in your save from the last exercise

*2
sort age
list age height in 1/20
gsort -height
list age height in -10/-1
sort id

*3
sum height, detail
replace height = . if height == -1 //Don’t forget you need a double equals sign for if statements
sum height, detail
replace bmi = . if height == .

*4
order bmi, after(weight)
order date_of_recruitment, before(age)

*5
preserve
drop id accommodation - smoking_status
drop if hair_colour == 5
keep if sex == "Female" | sex == "female"
*OR
drop if sex == "Male" | sex == "male" | sex == ""
keep age diastolic_bp
keep if age <= diastolic_bp/2 & diastolic_bp < .
count //Or look in the bottom right window or the spreadsheet view
restore

*6
sum age if (hair_colour == 1) | (height < 1.7 & (sex == "female" | sex == "Female"))
/*
The key part of the if statement is that the second OR statement has a nested OR statement: 
have a careful look at the brackets, because we want it to say "if the person is shorter than 1.7 metres AND is ("female" OR "Female")"
If you miss out those brackets, Stata will interpret the statement as 
"if the person is shorter than 1.7 metres AND "female", OR if the person is "Female"", 
which includes people who are "Female" of any height
Liberally using brackets until you’re certain you have the right if statement 
is usually the best way to go, and the more of these you do the more intuitive it will become
*/
gen x = 1 if (hair_colour == 1) | (height < 1.7 & (sex == "female" | sex == "Female"))
list age hair_colour sex height x in 1/20
sort hair_colour
browse
sort id
drop x

*7
replace sex = "Male" if sex == "male"
replace sex = "Female" if sex == "female"
/*
We haven’t covered this yet, but there’s also a command that capitalises 
the first letter of all words in a string, 
and this would also work (we’ll cover commands to manipulate strings in the next lesson):
*/
replace sex = proper(sex)

*8
tab sex marathon if bmi > 25 & bmi < .
*Make sure you account for missing values!

*9
gen bmi_categories = 0 if bmi < 25
replace bmi_categories = 1 if bmi >= 25 & bmi < 30
replace bmi_categories = 2 if bmi >= 30 & bmi < .
label define bmi_categories 0 "<25" 1 "25-30" 2 "30+"
label values bmi_categories bmi_categories
label variable bmi_categories "Categorical BMI"
order bmi_categories, a(bmi)

*10
bysort bmi_categories: tab sex income, col
/*
You could also do this with a series of tabulate commands with if statements, but using by is quicker
The answers are as follows:
i.	BMI < 25 kg/m2 = 54.24%
ii.	BMI 25 – 30 kg/m2 = 40.74%
iii.BMI 30+ kg/m2 = 60.00%
iv.	BMI missing = 63.64%
*/

*11
gen sex2 = 0 if sex == "Male"
replace sex2 = 1 if sex == "Female"
label define sex 0 "Male" 1 "Female"
label values sex2 sex
*There’s a variable called encode that can do these steps for you, more on that in the next lesson
label variable sex2 "Sex (numeric)"
order sex2, a(sex)

*12
replace smoking_status = 0 if smoking_status == 2
label variable smoking_status "Smoking status 0 = No, 1 = Yes"
label define yes_no 0 "No" 1 "Yes"
label values smoking_status marathon yes_no

*13
label variable age "Age (years)"
label variable weight "Weight (kg)"

*14
save "Exercise_03_SH.dta", replace
save "Exercise_04.dta", replace // Used to create a working copy of the dataset for exercise 4 in case of any errors

*****************************************************

*Exercise 04
*1
cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"
use "Exercise_03_SH.dta", clear
*use "Exercise_04.dta", clear //if you’re not confident in your save from the last exercise

*2
gen calories_string = string(calories,"%9.1f")
*OR*
*tostring calories, gen(calories_string) format(%9.1f) force
gen calories_numeric = real(calories_string)
*OR*
*destring calories_string, gen(calories_numeric)
/*
The newly created numeric variable will necessarily be limited to 1 decimal place, 
since that’s how many decimal places the string was created with. 
Therefore, the new variable won’t be exactly the same as the original calories 
variable, as that has more than 1 decimal place. 
It will be the same to 1 decimal place though.
*/
drop calories_*

*3
encode sex, gen(sex3) label(sex)
order sex3, a(sex2)
tab sex sex3, miss
tab sex2 sex3, miss
drop sex sex2
rename sex3 sex

*4
merge 1:1 id using "Exercise_04_merge.dta", nogen 

*5
replace favourite_dog_breed = subinstr(favourite_dog_breed,"Retriver","Retriever",.)

*6
split favourite_dog_breed, gen(breed_) parse(;)
label variable breed_1 "1st favourite dog breed"
label variable breed_2 "2nd favourite dog breed"
label variable breed_3 "3rd favourite dog breed"
label variable breed_4 "4th favourite dog breed"
order breed_*, a(favourite_dog_breed)
egen favourite_dog_breed_2 = concat(breed_1 breed_2 breed_3 breed_4), punct(";")
count if favourite_dog_breed == favourite_dog_breed_2
*OR*
gen favourite_dog_breed_3 = breed_1 + ";" + breed_2 + ";" + breed_3 + ";" + breed_4
count if favourite_dog_breed == favourite_dog_breed_3
drop favourite*
replace breed_1 = strtrim(breed_1)
replace breed_2 = strtrim(breed_2)
replace breed_3 = strtrim(breed_3)
replace breed_4 = strtrim(breed_4)

*7
tab breed_1
tab breed_2
tab breed_3
tab breed_4
/*
We can see by tabulating the breed variables that each variable 
has 9 breeds, and they all look the same in each variable
*/
gen x = length(breed_1)
sum x, detail
*OR*
tab breed_1 x
/*
Either by summarizing or tabulating breed_1 and x, 
we can see the “German Shorthaired Pointer” has the most characters, 
at 26 characters
*/
drop x

*8
encode breed_1, gen(breed_1x) label(breed)
encode breed_2, gen(breed_2x) label(breed)
encode breed_3, gen(breed_3x) label(breed)
encode breed_4, gen(breed_4x) label(breed)
tab breed_1 breed_1x
tab breed_2 breed_2x
tab breed_3 breed_3x
tab breed_4 breed_4x
*i.	All the tabulations look the same, so the encoding worked
drop breed_1-breed_4
rename breed_1x breed_1
rename breed_2x breed_2
rename breed_3x breed_3
rename breed_4x breed_4

*9
gen date_of_bp_measurement_2 = date(date_of_bp_measurement,"DMY")
format date_of_bp_measurement_2 %td
label variable date_of_bp_measurement_2 "Date of blood pressure measurement"
order date_of_bp_measurement_2, a(date_of_recruitment)
drop date_of_bp_measurement
rename date_of_bp_measurement_2 date_of_bp_measurement

*10
format calories %9.0f
format weight %9.2f
format bmi %9.1f
format date_of_recruitment %td

*11
save "Exercise_04_SH.dta", replace
save "Exercise_05.dta", replace // Used to create a working copy of the dataset for exercise 5 in case of any errors

*********************************************************

*Exercise 05
*1
use "Exercise_04_SH.dta", clear
*use "Exercise_05.dta", clear //if you’re not confident in your save from the last exercise

*2
local number = 12
dis `number'*8
local number = `number'^2
dis `number'/3
dis sqrt(`number'/3+1)

*3
local first_name "Sean"
local last_name "Harrison"
display "`first_name' `last_name'"
display upper("`first_name' `last_name'")

*4
global date = date("07/03/2021","DMY")
global day_week = "Sunday"
global day_month = "7th"
global month = "March"
global year = 2021
dis "Today is $day_week the $day_month of $month, $year, which in Stata code is: $date"

*5
local height = height[2]
local weight = weight[2]
local bmi = string(bmi[2],"%9.1f")
local bmi2 = string(`weight'/`height'^2,"%9.1f")
dis "BMI in 2 = `bmi', and BMI from height/weight = `bmi2'"

*6
qui sum weight, d
global median = string(r(p50),"%9.1f")
global lower = string(r(p25),"%9.1f")
global upper = string(r(p75),"%9.1f")
global min = string(r(min),"%9.1f")
global max = string(r(max),"%9.1f") 
dis "The median (IQR) of weight is: $median ($lower to $upper), and the range is $min to $max"

*7
qui sum height
local mean = r(mean)
local sd = r(sd)
gen height_norm = (height-`mean')/`sd', a(height)
sum height_norm
label variable height_norm "Height(normalised)"
su height_norm

*8
save "Exercise_05_SH.dta", replace
save "Exercise_06.dta", replace // Used to create a working copy of the dataset for exercise 5 in case of any errors


