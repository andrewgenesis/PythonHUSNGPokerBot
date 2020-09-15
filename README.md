# PythonPokerBot
AI poker bot based on research papers\n
Approximates Nash Equilibrium with Monte Carlo Linear Counterfactual Regret Minimization\n
Note:\n
       Does NOT exploit bad play, plays according to an unexploitable strategy itself.\n
       Exploiting bad play would actually open up bot to exploitation by others, therefore not NE.\n
       https://arxiv.org/abs/1401.4591\n
       MCCFR has "theoretical NE convergence guarantees in such a game [as poker]."\n
       This article also describes MCCFR and Restricted Nash Response (RNR) for exploitation.\n
       Could be interesting to apply these as well.\n
\n
\n
python3 setup.py build_ext --inplace\n
Do python3, import Bot, Bot.startBotTraining()\n
Strategy file is size 0 while writing\n
\n
