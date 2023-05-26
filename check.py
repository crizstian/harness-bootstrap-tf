import json

elements = []
i = 0
with open('checkov/results_json.json') as data_file:    
    info = json.load(data_file)
    for data in info:
        for v in data["results"]["failed_checks"]:
            i+=1
            element = {}
            element["id"]=v["check_id"]
            element["bc_id"]=v["bc_check_id"]
            element["issueName"]=v["check_name"]
            element["issueDescription"]=v["description"]
            element["fileName"]=v["file_path"]
            element["remediationSteps"]=v["check_class"]
            element["risk"]=v["guideline"]
            element["status"]=v["check_result"]["result"]
            element["cvss"]=v["check_id"]
            element["issueType"]=data["check_type"]
            element["lineNumber"]=v["file_line_range"]
            element["product"]=v["resource"]
            element["scanTool"]="checkov"

            element["severity"]=5
            element["type"]=data["check_type"]
            elements.append(element)

    results = {}
    results["meta"] = {}
    results["meta"]["key"]=[  
                "issueName",  
                "fileName"  
            ]
    results["meta"]["author"]="Checkov"
    results["issues"]=elements

with open('checkov.json', 'w') as f:
    json.dump(results, f, indent=2)
    print("Nuevo resporte de lint generado")