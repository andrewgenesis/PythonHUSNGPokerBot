# PythonPokerBot
AI poker bot based on research papers  
Approximates Nash Equilibrium with Monte Carlo Linear Counterfactual Regret Minimization  
Note:  
       Does NOT exploit bad play, plays according to an unexploitable strategy itself.  
       Exploiting bad play would actually open up bot to exploitation by others, therefore not NE.  
       https://arxiv.org/abs/1401.4591  
       MCCFR has "theoretical NE convergence guarantees in such a game [as poker]."  
       This article also describes MCCFR and Restricted Nash Response (RNR) for exploitation.  
       Could be interesting to apply these as well.  
  
  
python3 setup.py build_ext --inplace  
Do python3, import Bot, Bot.startBotTraining()  
Strategy file is size 0 while writing  
  
  
