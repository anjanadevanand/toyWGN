## Toy package to implement R functionality
## Considerations for creating an R-Package

### 1.	Basic elements of setting up a package, including naming, directory structure and so forth.  

> __Naming:__ Can contain letters, numbers and periods. It must start with a letter and cannot end with a period. Wickham recommends against using periods to avoid confusion with the names of S3 methods. He also recommends against using a mix of uppercase and lowercase letters - since it makes the package name hard to remember and type.    
>  
> Directory Structure inside the top-level directory __package_name/__  
>   
> __R/__ - contains code in *.R files  
>  
> __tests/__  
>  
> __data/__ - contains *.rda files that are to be distributed with the package. May contain files in *.R or *.csv formats as well.    
>  
> __man/__ - contains *.Rd files for documentation of package, functions and data. These files may be written manually or created using roxygen2.  
>  
> __inst/__ - can contain any files. Typically contains copyrights and citation files. The contents of this directory will be recursively copied to the top-level directory after installation. So the filenames in this directory should be distinct from the original contents of the top-level directory.  
>  
> __src/__ - contains *.cpp files  
>  
> Other directories: __demo/__,  __exec/__, __po/__, __tools/__, __vignettes/__  
>  
> Note: README.md appears to be a valid top-level directory component in a bundled source package

### 2.	Include detailed documentation. What forms of documentation should accompany the code (e.g. help files, readme files, vignettes, comments)? Can you implement roxygen and rmarkdown?  

> Write .Rd files in the man/ directory of the package  
> roxygen2: can be used to create *.Rd files in the man/ directory for documentation. These files are used for documentation of the package, functions, and data. roxygen2 turns specifically formatted comments into .Rd files. It can also manage NAMESPACE and the Collate field in DESCRIPTION.  
  
_Note1_: The subscripts and superscripts in equations are not rendered correctly using roxygen2, need to look into this.  
  
_Note2_: Add NULL after @import or @importFrom roxygen comments, if these comments are used at the beginning of the file, separate from the comment block for a function.   

*yet to look into vignettes

### 3.	Think about how you store data in the package (hint: there are at least two directories in the package where you can store data). Are there situations where JSON or YAML formats are useful for including as part of an R package? In foreSIGHT there are a number of ‘data’ categories that are hard-coded within functions (e.g. default parameter values) and I’m wondering whether this should be separated out from the function and included as a distinct file.

> Data may be stored in four directories in a package:  
> 
__1. data/__  
> Directory to store data that is to be released as part of the package. Data files should not typically exceed 1 MB in size for CRAN release; must be optimally compressed. Wickham recommends that the data be stored in RData files containing a single object with name same as the filename.  
>  
> Can use the command `usethis::use_data(data1, data2)` to create data1.rda and data2.rda files in the data directory.  
>  
> Other types of data files this directory may contain as per the CRAN manual: "plain R code (.R or .r), tables (.tab, .txt, or .csv, see ?data for the file formats). Note that R code should be if possible “self-sufficient” and not make use of extra functionality provided by the package, so that the data file can also be used without having to load the package or its namespace: it should run as silently as possible and not change the search() path by attaching packages or other environments" 
>    
__2. R/sysdata.rda__  
> To store data that is not available to the users of the package. This is the place to keep data that the functions in the package need. The function objects are created at installation, and these files are not required thereafter.  
>   
__3. inst/extdata__  
> Directory to store raw data. Raw data may be included as part of a package for examples or vignettes. Are the raw data files typically in JSON/YAML formats?  
>    
> The contents of __inst/__ are recursively copied to the top-level directory after installation. To find a file in __inst/__ from the code use system.file() function.  
>   
> Example: `system.file( “extdata”, “mydata.csv”, package = “mypackage”)`. Note: the __inst/__ directory is omitted from the path specified (arg1) in the system.file function call.  
>   
__4. tests/__  
> It is okay to keep small data files for tests in this directory.  
>  
#### Notes on where to keep data typically hardcoded in a package:
> If the default data should not be available as data files to the users - they may have to be stored as sysdata.rda in the __R/__ directory.  
>  
> If the data may be available to the users:  
> The data can be created using a *.R file in __data/__ folder. Potential advanatge of this method over keeping the data inline with the code - ease of editing default parameters used by the functions in one single file in a central location. The *.R file would also be more readable than *.RData files in the __data/__ directory or sysdata.rda files in the __R/__ directory.  
>  The disadvantage could be a dissociation of data from the code that uses it [Reference link 3]  
>  
>  Reference links:
>  1.  https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Data-in-packages  
>  2.  https://stackoverflow.com/questions/47499671/how-to-store-frequently-used-data-or-parameters-within-an-r-package  
>  3.  https://community.rstudio.com/t/creating-global-object-vs-storing-it-as-sysdata-rda/3022  
>  4.  https://owi.usgs.gov/R/training-curriculum/r-package-dev/mechanics/  
>  
#### Examples from other packages
>  Separate package for a huge dataset that can be used by multiple other packages: https://github.com/hadley/nycflights13  
>  Package that contains R code to generate data in the __data/__ directory: https://github.com/cran/stacomiR/blob/master/inst/config/generate_data.R. Note: This is different from keeping an *.R code directly in the __data/__ directory.  
>   
#### Package wide global variables stored in an separate environment?
> 1. https://stackoverflow.com/questions/12598242/global-variables-in-packages-in-r  
> 2. https://www.r-bloggers.com/global-variables-in-r-packages/   
> 3. https://www.r-bloggers.com/package-wide-variablescache-in-r-packages/  
>  
>  Parameters of the WGN are stored in a separate environment in this package.  

### 4.	Develop a condition system that traps errors and provides useful warnings. What does this do not only to code robustness, but also to your coding style? 

> Custom conditions are used to output metadata of errors and provide more useful error messages for function arguments. I have used `rlang::abort()` to signal errors of the same style and store additional metadata about the error (Advanced R, Ch 8.5). The advantage of `rlang::abort()` over `base::stop()` is the ability to contain metadata.
>  
> Note: More complicated wrappers for conditionhandlers are mentioned in Chapter 8 of the Advanced R book. These applications are:  
>   
> 1.	To set the default failure value in case of an error  
> 2.	To set both success and failure values while evaluating code  
> 3.	To convert warning messages to errors and stop execution  
> 4.	To record conditions for later investigation  
> 5.	To implement a logging system based on conditions  
>   
> I can revisit these if they are useful for implementation in foreSIGHT. 
>  
#### Effects of condition system on coding syle (custom condition system vs. default stop messages): 
> -  Output error messages of same style in the package (error_bad_argument, error_infeasible_argument, error_argument_dimension)  
> -  When custom conditions are in place, the code is more uniform to read.  
> -  The condition system leads you to classify potential errors into groups (eg: type-mismatch, dimension mismatch, infeasible range), so that each group may be handled with a common type of custom error message. This also serves as a reminder to include all the potential error checks while writing new functions.  
> 
#### Additional Discussion Points  
> Where should you signal errors that occur due to user input?  
> - At the time of input. If the parameter input is separate from the function call that uses the parameters, a checker function may be used to signal errors and warnings immediately at the time of input.  
> - At the top level function call.  
> - At the level of internal function call.  Here the user may need to go through multiple iterations to fix the same error in multiple instances.  
>  
> Condition system for internal functions that do not interact with user inputs?  
> 
**********************
#### Notes on Conditions and Condition Handling
##### Conditions
> Base R functions: `stop("Error")`, `warning("warning message")`, `message("informative message")`  
> `rlang` equivalent to `stop("Error")` : `rlang::abort("Error")`, which can store additional metadata about the error.
> Tidyverse style guide includes recommendations for writing informative error and warning messages. See Point 6 below for a Summary.  
> 
##### Ignore Conditions  
> Base R functions: `try()`, `suppressWarnings()`, `suppressMessages()`  
> 
##### Handle Conditions  
> Conditionhandlers are used to supplement or temporarily override the default behaviour in case of a condition (error, warning, message)
> Condition object: List with 2 elements, 
> - `message` : a character vector containing text to display. Can be accessed using `conditionMessage(cnd)`    
> - `call` : call that triggered the condition. Can be accessed using `conditionCall(cnd)`  
>   
> Base R functions to handle a condition object: `tryCatch()`, `withCallingHandlers()`  
> Custom conditions can be created using `rlang::abort()` to store additional information about the error to use for debugging.  
    
### 5.	Use GitHub to help with version control (Sam can get you set up with a private account). Also develop an opinion on version numbering for your own package (e.g. when do you change version numbers, etc)
#### Helpful GitHub training presentation
> https://github.com/IMMM-SFA/git-training/blob/master/materials/Presentation.pptx
> 
#### Version Numbering  
> major.minor.patch  
> https://semver.org/#faq  
> https://blog.codeship.com/best-practices-when-versioning-a-release/  
>  
### 6.	Think about a coding style guide. Hadley Wickham has developed one, and Google has made some suggested modifications (the link to this is mentioned in either the R Packages book or the Advanced R book). Why do you think Google has departed from Hadley’s style guide and which one do you think is better? Which one should we be using? 
>  
__Function names:__
> - Tidyverse syle guide recommends using `snake_case` for all objects - using verbs for function names and nouns for other objects.   
> - Google style guide recommends using `BigCamelCase` for function names to distinguish them from other objects.  
> - Since foreSIGHT currently uses `smallCamelCase` for function names, it may be better to stick with it. 
>  
__Internal functions:__
> - Google style guide recommends starting internal functions with a period (`.`). 
> - Tidyverse style guide does not mention a different naming convention for internal functions. They recommend identifying internal functions using specifc roxygen tags in the documentation `@keywords internal` and `@noRd`.  
>
__Error messages:__
> 
***************

### 7.	Implement unit testing in the package throughout, using the Test That package. What does unit testing do to your coding style? Does it change how you implement functions in R?

#### Notes on Unit Testing
> Formal automated testing using the `testthat` package.  
> Test files are to be placed in the `test/testthat` directory. `testhat` package has to be added to the Suggests field in description. Use `devtools::test()` to run the tests.  
> - A **file** groups together multiple related tests  
> - A **test** groups together multiple expectations. A test is created using `test_that()`.
> - An **expectation** is the simplest form of testing. It describes the expected result of a computation. An example test:  

```R
test_that("functionality description", {
  expect_equal(fun(x1), value1)
  expect_equal(fun(x2), value2)
  expect_equal(fun(x3), value3)
  })
```

> Commonly used expectations: `expect_equal()`, `expect_identical()`, `expect_match()`, `expect_output()`, `expect_warning()`, `expect_error()`, `expect_is()`, `expect_true()`, `expect_false()`, `expect_equal_to_reference()`
>  

### 8.	In addition to the core part of the code (i.e. the key algorithm), think about data input and output, plotting, diagnostics (e.g. does the stochastic generator simulate the same statistics as the observed data?), and so forth. I anticipate you’ll be writing quite a few functions for these features. 

### 9.	Implement plotting using the default R plots, as well as ggplot. What is the difference in approach? Do you have a preference? Read the ggplot book and form a view in terms of why this is becoming so popular but also why some people do not like it. 

### 10.	Implement some of the core algorithms in C++ using the RCpp package. There is a chapter on doing this and some basic C++ commands in the Advanced R book. 

### 11.	Implement the three different object systems (S3, S4, R6). What is the difference between them? When should you use one over the other? 

### 12.	Test for speed – what are different techniques to evaluate code speed, and diagnose computational bottle necks? Does the C++ code improve efficiency in this case? Does it depend on the order (‘O’) of computations – e.g. length of replicates etc. What can you say about how run time scales with length of replicates, vectors and so forth? Does it depend on the nature of the algorithm?  

### 13.	Read The Pragmatic Programmer. What does implementation of DRY (pg 30) mean for your particular code? What is decoupling? How to you create orthogonality in code? What are some of the key messages in the ‘test to code’ chapter? Why ‘refactor’?
