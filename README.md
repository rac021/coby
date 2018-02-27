
# coby

### Clone the project :

-  Make sure using the option "--recursive" when cloning the project, this allows include the submodules

   `  git clone --recursive https://github.com/rac021/coby.git . `
  
----------------------------------------------------------------------------------

### 1. Coby standard_build :

   `  ./01_coby_standard_builder.sh `
   
#####   Example : Copy "SI" + "orchestrators" to the coby_standard_build directory ( created by the previous script )

   `  ./coby_standard_build/pipeline/orchestrators/synthesis_extractor_entry.sh `
   
----------------------------------------------------------------------------------

### 2. Coby docker_build :

   `  ./02_coby_docker_builder.sh `
   
#####   Example : Run coby_docker using orcherstrators ( located in src ) + SI modelization ( locate in src ) :
  
   `  ./docker_runner.sh `
   
----------------------------------------------------------------------------------

### 3. Example of how calling scripts that are provided by coby Using Coby standard_build :

   ` ./coby_standard_bin/pipeline/scripts/06_gen_mapping.sh input=`pwd`/Demo/Demo_1/ output=`pwd`/Demo/Demo_1/mapping.obda `
   
   
