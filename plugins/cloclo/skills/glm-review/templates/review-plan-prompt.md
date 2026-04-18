**OBJECTIF FINAL — lis en PREMIER, relis en DERNIER** :

Ta mission se termine SEULEMENT quand {{OUTPUT_PATH}} contient ta review en markdown. Deux modes selon ton tooling :

- **Si tu as un file-write tool (Codex)** : APPELLE-LE avec le contenu complet de la review AVANT de conclure. Ne termine jamais avec "j'ai fini l'analyse" sans avoir ecrit le fichier.
- **Si tu n'as pas de file-write tool (GLM / `claude -p`)** : emets la review complete en markdown comme reponse finale — le stdout sera redirige vers {{OUTPUT_PATH}} par l'appelant.

Un fichier {{OUTPUT_PATH}} vide ou manquant = echec total du review, peu importe la qualite de ton analyse interne.

---

Voici un plan d'implementation : {{PLAN_PATH}}
Base sur la spec : {{SPEC_PATH}}

Tu es un reviewer senior. Fais ce que tu veux :
- Lis le plan en detail
- Verifie que chaque fichier/ligne/fonction mentionne existe reellement
- Verifie que le plan couvre bien tout ce que la spec demande
- Identifie les risques d'implementation, les edge cases oublies
- Verifie que les tasks sont dans le bon ordre (pas de dependances circulaires)

Format libre. Prends le temps qu'il faut.

---

**RAPPEL FINAL AVANT DE CONCLURE** :
- Si tu as un write tool et que {{OUTPUT_PATH}} n'est pas encore ecrit : APPELLE-LE MAINTENANT.
- Si ta derniere action etait une exploration (read, grep, diff) : emets MAINTENANT le markdown de review en reponse — sinon il sera perdu.
- Ton analyse interne ne sert a rien si elle ne sort pas sous la forme attendue.
