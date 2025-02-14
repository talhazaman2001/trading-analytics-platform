#!/bin/bash
OUTFILE="../../sample-data/sample-trades.log"

SYMBOLS=("AAPL" "GOOGL" "MSFT" "AMZN" "META" "NVDA" "TSLA" "JPM" "BAC" "GS")

mkdir -p "../../sample-data"

generate_trade() {
    local symbol=${SYMBOLS[$RANDOM % ${#SYMBOLS[@]}]}
    local base_price
    base_price=0
    case "$symbol" in
        "AAPL")  base_price=180 ;;
        "GOOGL") base_price=140 ;;
        "MSFT")  base_price=400 ;;
        "AMZN")  base_price=175 ;;
        "META")  base_price=500 ;;
        "NVDA")  base_price=800 ;;
        "TSLA")  base_price=175 ;;
        "JPM")   base_price=175 ;;
        "BAC")   base_price=35 ;;
        "GS")    base_price=380 ;;
    esac
    
    local variation=$(( RANDOM % 20 - 10))
    local price=$(( base_price + variation ))
    local volume=$(( RANDOM % 1000 + 100))
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    
    echo "$timestamp $symbol $price $volume"
}   >> $OUTFILE 

for ((trade=1; trade<=1000; trade++)); do
    generate_trade >> $OUTFILE
    
    # Show progress every 100 trades
    if (( trade % 100 == 0 )); then
        echo "Generated $trade trades..."
    fi
done

echo "Completed generating 1000 trades in $OUTFILE"

# Display first few trades as sample
echo -e "\nSample of generated trades:"
head -n 5 $OUTFILE
