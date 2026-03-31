⚡ EV Penetration Forecasting Model (India 2010–2040)

A research-oriented forecasting engine written in Haskell that predicts long-term Electric Vehicle (EV) adoption in India using mathematical diffusion models and real-world economic drivers.

📌 About The Project

Electric vehicle adoption is not linear.
It behaves like a technology diffusion problem influenced by infrastructure, economics, and social behavior.

Most EV forecasts focus only on sales growth.
This project instead models EV adoption as a real-world system constrained by:

Charging infrastructure
Battery price decline
Fuel price pressure
Economic growth
Social adoption (word-of-mouth)
Power grid limitations

The system generates yearly EV adoption forecasts from 2010 → 2040.

🎯 Project Goal

Build a realistic and explainable EV adoption model using pure functional programming and mathematical growth models.

This project is designed for:

Academic research
Sustainability studies
Data science projects
Technology adoption modeling
🧠 Models Used

The forecasting engine combines multiple well-known adoption models.

1️⃣ Logistic Growth — Market Saturation

Estimates the maximum EV capacity the market can support.

Growth pattern:
Slow → Rapid → Saturation

Represents the upper limit of EV adoption.

2️⃣ Gompertz Curve — Infrastructure Delay

Models the slow start of new technologies due to high costs and low infrastructure.

Perfect for early EV adoption behavior.

3️⃣ Bass Diffusion — Social Adoption

Models how adoption spreads through people influencing people.

Splits adopters into:

Innovators (early adopters)
Imitators (mass market)

Captures the neighbor effect.

4️⃣ ARIMAX — Economic Driver Model

Adds real-world economic variables:

GDP growth → purchasing power
Fuel prices → motivation to switch
Battery prices → affordability
Market saturation → prevents unrealistic growth

This acts as the economic correction layer.

🔮 Hybrid Ensemble Model

Instead of trusting a single model, this project builds a Hybrid Forecast by combining all models.

Model weights change over time:

Phase	Years	Dominant Factors
Incubation	2010–2024	Social + Infrastructure
Rocket Growth	2025–2030	Fleet adoption + charging expansion
Mature Market	2031–2040	Market saturation + economics

The hybrid model also self-corrects using historical EV data.

📊 Output

The program generates:

📄 CSV forecast dataset (2010–2040)
📈 Logistic, Gompertz and Hybrid predictions
🌐 Interactive Plotly dashboard (HTML)
📉 Comparison between actual & predicted data
🛠 Tech Stack
Component	Technology
Language	Haskell
Visualization	Plotly (JavaScript)
Data Output	CSV
Modeling Style	Pure Functional Programming
📁 Project Structure
├── Main.hs                → Full hybrid forecasting engine
├── Main_NoFactors.hs      → Simplified baseline model
├── DataReader.hs          → CSV data loader
├── GraphData.hs           → Graph record formatter
├── index.html             → Interactive visualization dashboard
├── results.csv            → Forecast output
├── research_output_2040.csv → Final research dataset
▶️ How To Run

1️⃣ Install Haskell (GHC)

2️⃣ Compile the project

ghc Main.hs

3️⃣ Run the forecasting engine

./Main

This will generate:

research_output_2040.csv

4️⃣ Open the dashboard

index.html
💡 Why Haskell?

This project intentionally uses Haskell because:

Pure functions = no hidden side effects
Deterministic math calculations
Strong type safety for research models
Reproducible forecasting pipeline
🧾 Summary

This project shows how EV adoption should be modeled as a complex socio-economic system, not just a simple trend.

By combining:

Mathematical diffusion models
Economic variables
Infrastructure constraints
