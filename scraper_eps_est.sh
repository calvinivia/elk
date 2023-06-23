symbols=(
"AAPL"
"TSLA"
"NVDA"
"MSFT"
"SBUX"
"GOOGL"
"AMD"
"MCD"
"BAC"
"JPM"
"AMZN"
"TSM"
"CMG"
"BRK-B"
"JNJ"
"KO"
"MA"
"PYPL"
"JNJ"
"UNH"
"XOM"
"V"
"PG"
"PEP"
"CVX"
"HD"
"ADBE"
"CRM"
"NFLX"
)

links=()

for i in "${symbols[@]}"; do
  links+=("https://finance.yahoo.com/quote/$i/analysis?p=$i")
done



for i in "${!symbols[@]}"; do
  echo "scraping ... ${symbols[i]}"
  lynx -dump "${links[i]}" |grep -A 6 "Earnings Estimate" | tail -n -5 > ./scraped_data/"${symbols[i]}"_scraped.txt
done

for i in "${symbols[@]}"; do
  cat ./scraped_data/"$i"_scraped.txt | sd '[a-z]' '' | sd '[A-Z].' '' | sd '\n[ ]*' '\n' | sd '\A\s+' '' > ./scraped_data/"$i"_processed.txt
done


