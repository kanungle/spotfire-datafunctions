
from fuzzywuzzy import fuzz
import pandas as pd

# Input Parameters: column1, column2, score
# Output Parameters: output

output = pd.DataFrame(columns=['Key1', 'Key2', 'Score'])

# Iterate through each item in column1 and compare it to each item in column2
for item1 in column1:
    for item2 in column2:
        ratio = fuzz.ratio(item1, item2)
        if ratio >= score:
            new_row = pd.Series({'Key1': item1, 'Key2': item2, 'Score': ratio})
            output = pd.concat([output, pd.DataFrame([new_row])], ignore_index=True)
