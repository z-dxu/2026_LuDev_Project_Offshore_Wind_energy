# ✨ Arcadia: Offshore Wind Energy Simulation✨
# How to Run the Game
# Running from the Godot Editor
* Clone the repository:
* Open Godot Engine.
* Click Import.
* Select folder containing the project.godot file
* Open the project.
* Press F5 or click Run Project.
# Running a Released Build
* Download the latest release from the Releases page.
* Extract the downloaded archive.
* Run the executable
# Controls
* left-clieck to interact with the point of interests and to continue the dialgoue
* right-click to move the camera around

# Overview

Arcadia is an interactive game that places players in the role of a government decision maker responsible for overseeing the development of an offshore wind park.

Players must balance competing interests from environmental organizations, fishing communities, tourism representatives, energy experts, and legal advisors while working toward sustainable development goals (SDGs).

Every decision has consequences. Choices affect environmental protection, renewable energy production, economic development, food security, and compliance with international law.

#Learning Objectives

The game aims to help players:

* Understand the complexity of sustainable development decisions.
* Explore trade-offs between competing SDGs.
* Learn about international environmental agreements and obligations.
* Evaluate stakeholder perspectives in policy-making.
* Experience the challenges of balancing environmental, social, and economic priorities.

# Sustainable Development Goals

The game focuses on several UN Sustainable Development Goals:
* SDG 1 – No Poverty
* SDG 2 – Zero Hunger
* SDG 7 – Affordable and Clean Energy
* SDG 8 – Decent Work and Economic Growth
* SDG 13 – Climate Action
* SDG 14 – Life Below Water
* SDG 15 – Life on Land

# Gameplay
# Phase 1: Exploration
Players visit Points of Interest (POIs) and gather information from stakeholders.
Each stakeholder presents different concerns and priorities.
* Phase 2: Intervention
After gathering information, players must choose how to respond to challenges.
Examples include:

* Creating artificial reefs
* Supporting fishers during economic transitions
* Painting turbine blades
* Seasonal turbine shutdowns
* Using suction bucket foundations
* Installing bubble curtains
# Phase 3: Evaluation
The game evaluates the player's decisions and determines an outcome based on the combined effects of their choices.
Possible outcomes include:

* Good Ending
* Mixed Ending
* Bad Ending

# Dialogue System

The game uses JSON-based dialogue files.

Example:
```
{
  "speaker": "LEGAL ADVISOR",
  "text": "Arcadia must balance environmental protection and economic development."
}
```
Choices can be defined as:
```
{
  "type": "choice",
  "text": "How should Arcadia respond?",
  "options": [
    {
      "label": "Create artificial reefs"
    },
    {
      "label": "Move the wind park"
    }
  ]
}
```
Scoring
Player choices contribute to sustainability outcomes across multiple SDGs.
The final score is based on the choices the player made

This project was developed as an educational game exploring sustainability challenges surrounding offshore wind energy development.

License

This project is provided for educational purposes.

# Group 9
