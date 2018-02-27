
# coby

### Clone the project :

-  Make sure using the option "--recursive" when cloning the project, this allows include the submodules

   `  git clone --recursive https://github.com/rac021/coby.git . `
  
<p><a href="https://www.youtube.com/watch?v=ruZTuK-ui2s?rel=0" rel="nofollow"><img src="https://user-images.githubusercontent.com/7684497/36728847-7668397a-1bc2-11e8-9050-27858bb3b343.png" alt="Intro" data-canonical-src="https://i.ytimg.com/vi/20KVZ0ZnCl4/mqdefault.jpg" style="max-width:10%;"></a></p>

----------------------------------------------------------------------------------

### 1. Coby standard_build :

   `  ./01_coby_standard_builder.sh `
   
      
 <p><a href="https://www.youtube.com/watch?v=l08JIPcqgrI?rel=0" rel="nofollow"><img src="https://user-images.githubusercontent.com/7684497/36728847-7668397a-1bc2-11e8-9050-27858bb3b343.png" alt="Intro" data-canonical-src="https://i.ytimg.com/vi/20KVZ0ZnCl4/mqdefault.jpg" style="max-width:10%;"></a></p>
  
   
#####  Coby standard_build Example :

-  Make sure Copy "SI" + "orchestrators" to the coby_standard_bin directory ( created by the previous script )

   `   cp -r src/SI/ coby_standard_bin/pipeline/ `
   
   `   cp -r src/orchestrators/ coby_standard_bin/pipeline/`
   
   
   `  ./coby_standard_bin/pipeline/orchestrators/synthesis_extractor_entry.sh `  

----------------------------------------------------------------------------------

### 2. Coby docker_build :

   `  ./02_coby_docker_builder.sh `
   
#####   Example : Run coby_docker using orcherstrators ( located in src ) + SI modelization ( locate in src ) :
  
   `  ./docker_runner.sh `
   
----------------------------------------------------------------------------------

### 3. Example of how calling scripts that are provided by coby Using Coby standard_build :

#### - 06_gen_mapping.sh

-  Without CSV

   ` ./coby_standard_bin/pipeline/scripts/06_gen_mapping.sh input=$(pwd)/Demo/Demo_1/ output=$(pwd)/Demo/Demo_1/mapping.obda `
-  SING CSV 

   ` ./coby_standard_bin/pipeline/scripts/06_gen_mapping.sh input=$(pwd)/Demo/Demo_2/physicochimie/ output=$(pwd)/Demo/Demo_2/mapping.obda class="physico chimie" column="12" csvFile="$(pwd)/Demo/Demo_2/csv/semantic_si.csv"
 `
   

