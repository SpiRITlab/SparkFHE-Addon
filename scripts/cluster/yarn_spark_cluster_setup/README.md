#### Objective: The objective of this script is to generate a sample Yarn-Spark cluster on Docker environment.
#### Pre-requisites: For now the image MulticloudSparkFHE should be used: 

#### Instructions:

1. **Start an experiment in MulticloudSparkFHE**

Copy the contents of Manifest.xml to base_directory/local_scripts/bash_scripts_library/Manifest.xml
Also type in the user name for Cloudlab in base_directory/local_scripts/bash_scripts_library/myUserName.txt
2. **Run the process from local**

Navigate to the folder base_directory/local_scripts used cd
Then run the automated script
```bash
bash run_all_processes_through_local.bash
```
This script will move all files to server, install hadoop and spark, run spark job on yarn network and remove all files when the job is done.
