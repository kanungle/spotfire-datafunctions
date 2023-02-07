import xml.etree.ElementTree as ET

def generate_readme(sfd_file, readme_filename):
    df_tree = ET.parse(sfd_file)
    df_root = df_tree.getroot()

    ## check we have minimum requirements
    if df_root.find("Description").text is None:
        raise Exception("All data functions must have descriptions - please check")

    ## create read me file
    readme_file = open(readme_filename,"w+")

    ## grab contents as required
    df_name = df_root.find('Name').text
    df_description = df_root.find('Description').text
    df_language = df_root.find('Language').text

    readme_file.write("# " + df_name + " Data Function for TIBCO Spotfire&reg;\n\n")
    readme_file.write(df_description + "\n\n")

    ## generic installation instrucitons
    readme_file.write("## Installing the data function\n\nFollow the [online guide available here](https://docs.tibco.com/pub/sfire-analyst/12.0.0/doc/html/en-US/TIB_sfire-analyst_UsersGuide/df/df_how_to_register_a_data_function.htm) to register a data function in TIBCO Spotfire&reg;" + "\n\n")
    readme_file.write("## Configuring the data function\n\nEach data function may require inputs from the Spotfire analysis and will return outputs to the Spotfire analysis. For each data function these need to be configured once the data function is registered. To learn about how to configure data functions in Spotfire please view this [YouTube Data Function guide](https://youtu.be/p1lRpujrvzM), and for more information on Spotfire visit the [Spotfire Enablement Hub](https://community.tibco.com/s/enablement-hubs/spotfire)\n\n")

    ## Describe inputs
    readme_file.write("## Data Function Inputs\n\nBelow is a table detailing all outputs from this data function\n\n")
    readme_file.write("|Name|Type|Display Name|Description|Requirement|Allowed Data Types|\n")
    readme_file.write("|:--- |:--- |:--- |:--- |:--- |:---|\n")

    ## loop over inputs
    for input in df_root.iter('Input'):
        if input.find("Description").text is None:
            raise Exception("All inputs must have descriptions - please check: " + input.find('Name').text)
        
        optional_text = "Mandatory"
        if input.find('IsOptional') is not None:
            optional_text = "Optional"

        ## get allowed data types
        allowed_types = [allowed_type.text for allowed_type in input.iter('AllowedDataType')]
        allowed_types = (', ').join(allowed_types)
        
        readme_file.write("|" + input.find('Name').text + "|" + input.find('Type').text + "|" + input.find('DisplayName').text + "|" + input.find('Description').text + "|" + optional_text + "|" + allowed_types + "|\n")

    ## Describe Outputs
    readme_file.write("## Data Function Outputs\n\nBelow is a table detailing all outputs from this data function\n\n")
    readme_file.write("|Name|Type|Display Name|Description|\n")
    readme_file.write("|:--- |:--- |:--- |:--- |\n")

    ## loop over inputs
    for output in df_root.iter('Output'):
        if output.find("Description").text is None:
            raise Exception("All outputs must have descriptions - please check: " + output.find('Name').text)
        
        readme_file.write("|" + output.find('Name').text + "|" + output.find('Type').text + "|" + output.find('DisplayName').text + "|" + output.find('Description').text + "|\n")

    readme_file.write("\n\n&copy; Copyright 2023. TIBCO Software Inc.")

    readme_file.close();

## Example usage
## set path to your directory containing your sfd file(s)
import os
rootdir = 'C:\\Users\\nkanungo\\Desktop\\New_DFs\\'

for subdir, dirs, files in os.walk(rootdir):
    for file in files:
        fullpath = os.path.join(subdir, file)
        if file.endswith(".sfd"):
            print(fullpath)
            print(subdir)
            sfd = fullpath
            generate_readme(sfd, subdir + "\\readme.md")

