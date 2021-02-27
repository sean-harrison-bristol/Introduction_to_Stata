*Lesson 1

cd "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Data files"

use "Exercise_01.dta", clear

save "G:\Documents\Online teaching\01 - Introduction to Stata\Stata\Exercise_01_SH.dta", replace

append using "Exercise_01_append.dta"

merge 1:1 id using "Exercise_01_merge.dta"

help merge

save "Exercise_01_SH.dta", replace
export excel using "Exercise_01_SH", firstrow(variables) replace

****************************************************

*Lesson 2

*1
use "Exercise_01_SH.dta", clear
*use "Exercise_02.dta", clear //if not confident with the saved dataset from the last exercise

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

****************************************************

*Lesson 3

*1
use "Exercise_02_SH.dta", clear
*use "Exercise_03.dta", clear

*2
sort age
list age height in 1/20
gsort -height
list age height in -10/-1
sort id

*3
sum height, detail
replace height = . if height == -1
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
count
restore

*6
sum age if (hair_colour == 1) | (height < 1.7 & (sex == "female" | sex == "Female"))
gen x = 1 if (hair_colour == 1) | (height < 1.7 & (sex == "female" | sex == "Female"))
list age hair_colour sex height x in 1/20
sort hair_colour
browse
sort id
drop x

*7
replace sex = "Male" if sex == "male"
replace sex = "Female" if sex == "female"
*OR
replace sex = proper(sex)

*8
tab sex marathon if bmi > 25 & bmi < .

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

*11
gen sex2 = 0 if sex == "Male"
replace sex2 = 1 if sex == "Female"
label define sex 0 "Male" 1 "Female"
label values sex2 sex
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
save "Exercise_04.dta", replace

*****************************************************

*Lesson 4

use "Exercise_03_SH.dta", clear
*use "Exercise_04.dta", clear

*1
gen calories_string = string(calories,"%9.1f")
*OR*
*tostring calories, gen(calories_string) format(%9.1f) force
gen calories_numeric = real(calories_string)
*OR*
*destring calories_string, gen(calories_numeric)
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
egen breed_1 = ends(favourite_dog_breed), punct(;) head trim
egen x = ends(favourite_dog_breed), punct(;) tail trim
egen breed_2 = ends(x), punct(;) head trim
egen x2 = ends(x), punct(;) tail trim
egen breed_3 = ends(x2), punct(;) head trim
egen x3 = ends(x2), punct(;) tail trim
egen breed_4 = ends(x3), punct(;) head trim
drop x*
label variable breed_1 "1st favourite dog breed"
label variable breed_2 "2nd favourite dog breed"
label variable breed_3 "3rd favourite dog breed"
label variable breed_4 "4th favourite dog breed"
order breed_*, a(favourite_dog_breed)
egen favourite_dog_breed_2 = concat(breed_1 breed_2 breed_3 breed_4), punct("; ")
count if favourite_dog_breed == favourite_dog_breed_2
drop favourite*

*7
tab breed_1
tab breed_2
tab breed_3
tab breed_4
gen x = length(breed_1)
sum x, detail
*OR*
tab breed_1 x
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

*********************************************************

