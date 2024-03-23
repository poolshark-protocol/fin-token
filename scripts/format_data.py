import json

# Open the JSON file and load its content
with open('./autogen/timeswap-lenders.json', 'r') as file:
    data = json.load(file)

lender_count = 0

# Iterate over the JSON objects and format each one
for index, lender in enumerate(data):
    lender_count += 1
    amount = data[lender]['lendTokenAmount']
    formatted_data = f"""
        data[{index}] = AirdropData(
            {{
                lender: {lender},
                amount: {amount}e6
            }}
        );
    """
    print(formatted_data)
print('lender count: ' + str(lender_count))