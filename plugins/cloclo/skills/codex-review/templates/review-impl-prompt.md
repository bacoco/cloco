**OBJECTIF FINAL — lis en PREMIER, relis en DERNIER** :

Ta mission se termine SEULEMENT quand {{OUTPUT_PATH}} contient ta review en markdown. Deux modes selon ton tooling :

- **Si tu as un file-write tool (Codex)** : APPELLE-LE avec le contenu complet de la review AVANT de conclure. Ne termine jamais avec "j'ai fini l'analyse" sans avoir ecrit le fichier.
- **Si tu n'as pas de file-write tool (GLM / `claude -p`)** : emets la review complete en markdown comme reponse finale — le stdout sera redirige vers {{OUTPUT_PATH}} par l'appelant.

Un fichier {{OUTPUT_PATH}} vide ou manquant = echec total du review, peu importe la qualite de ton analyse interne.

---

L'implementation suivante vient d'etre realisee.

Spec : {{SPEC_PATH}}
Plan : {{PLAN_PATH}}
Commits : {{COMMIT_LIST}}

Tu es un reviewer senior. Review le code qui a ete ecrit :
- `git diff {{BASE_REF}}..HEAD` pour voir tout ce qui a change
- Lis chaque fichier modifie en entier (pas juste le diff)
- Verifie que l'implementation correspond a la spec
- Verifie que l'implementation suit le plan
- Cherche les bugs, les edge cases, les regressions
- Lance les commandes de verification appropriees au projet

C'est une vraie code review. Prends le temps qu'il faut. Sois exhaustif. Signale tout ce qui te derange.

---

**RAPPEL FINAL AVANT DE CONCLURE** :
- Si tu as un write tool et que {{OUTPUT_PATH}} n'est pas encore ecrit : APPELLE-LE MAINTENANT.
- Si ta derniere action etait une exploration (diff, read, grep, test run) : emets MAINTENANT le markdown de review en reponse — sinon il sera perdu.
- Ton analyse interne ne sert a rien si elle ne sort pas sous la forme attendue.
