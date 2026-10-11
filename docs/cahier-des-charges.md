# CallPulse — Cahier des charges

- **Version :** 1.0 — figée au Jour 4 (tag `spec-v1.0`), alignée sur le [Product Backlog](backlog.md) ; toute modification ultérieure est consignée en section 12
- **Date :** 2026-10-11
- **Auteur :** Khadija
- **Documents de référence :** [VISION.md](../VISION.md), [ADR-001](adr/001-choix-techniques.md)

> Ce document détaille la vision du projet. En cas de doute, `VISION.md` fait référence : ce cahier des charges ne doit jamais la contredire.

---

## 1. Contexte et problématique

Dans un centre d'appels, le superviseur doit garantir la qualité de service tout en gérant une équipe d'agents dont la disponibilité change en permanence. Aujourd'hui, les informations dont il a besoin sont dispersées : les statuts des agents sont tenus à la main et souvent faux, l'état des files d'attente n'est visible qu'à travers des rapports de fin de journée, et la conformité au SLA (par exemple 80 % des appels décrochés en moins de 20 secondes) est constatée après coup.

Conséquences : les files saturées sont détectées trop tard, des clients raccrochent avant d'être servis, et des appels sont attribués à des agents qui n'ont pas la compétence nécessaire, ce qui provoque des transferts.

CallPulse est une plateforme web de supervision et d'optimisation qui donne au superviseur une vue en temps réel des agents, des files et du SLA, et qui affecte automatiquement les appels selon les compétences. Dans ce projet, les appels sont **simulés** par un générateur de trafic : il n'y a aucune intégration téléphonique réelle.

Le projet est aussi un support de formation DevOps sur 12 semaines : il sert à mettre en œuvre une chaîne complète, du commit jusqu'à l'alerte en production.

## 2. Objectifs

### 2.1 Objectifs métier

| ID | Objectif | Indicateur mesurable |
|----|----------|----------------------|
| OBJ-01 | Donner au superviseur une visibilité en temps réel sur les agents et les files | Un changement d'état (statut agent, nouvel appel en attente) apparaît sur le tableau de bord en moins de 1 s, sans rafraîchir la page |
| OBJ-02 | Affecter chaque appel à un agent compétent | 100 % des appels affectés automatiquement le sont à un agent qui possède la compétence requise par la file |
| OBJ-03 | Piloter le respect du SLA pendant la journée, et non après coup | Le taux de conformité SLA de chaque file est affiché en continu, et un indicateur visuel change d'état dès que le taux passe sous la cible |
| OBJ-04 | Fiabiliser les statuts des agents | Un agent change son statut en 1 clic ; le statut « En communication » est géré automatiquement (0 saisie manuelle) |
| OBJ-05 | Analyser l'activité passée | Les statistiques par agent, équipe et période, ainsi que le détail de chaque appel, sont consultables pour toute période d'au plus 31 jours |
| OBJ-06 | Centraliser l'administration | Toute modification des compétences, des files ou des cibles SLA est prise en compte par le routage dès l'appel suivant, sans redémarrage |

### 2.2 Objectifs techniques et pédagogiques

| ID | Objectif | Indicateur mesurable |
|----|----------|----------------------|
| OBJ-T01 | Mettre en place une intégration continue avec Jenkins | Chaque push sur `main` déclenche build, tests, analyse SonarQube et scan Trivy ; le pipeline échoue si une étape échoue |
| OBJ-T02 | Rendre l'application déployable partout | `docker compose up` démarre toute l'application ; `helm install` la déploie sur un cluster kind/k3s |
| OBJ-T03 | Observer l'application en fonctionnement | Les métriques métier sont visibles dans Grafana, les logs consultables via Loki, et une alerte SLA est émise par Alertmanager |
| OBJ-T04 | Tester à tous les niveaux | Tests unitaires (xUnit, Vitest), d'intégration (Testcontainers), de bout en bout (Playwright) et de charge (k6) exécutés dans le pipeline |
| OBJ-T05 | Construire une architecture maintenable | Monolithe modulaire en couches dont les dépendances sont vérifiées par des tests d'architecture ; chaque choix structurant est documenté dans un ADR |
| OBJ-T06 | Automatiser l'infrastructure et le déploiement | Environnement provisionné par Ansible ; déploiement automatique par ArgoCD après un merge sur `main` |

## 3. Périmètre

### 3.1 Dans le MVP / hors périmètre

| Dans le MVP | Hors périmètre |
|-------------|----------------|
| Authentification avec trois rôles : Agent, Superviseur, Administrateur | Téléphonie réelle (SIP, RTC, fournisseurs VoIP) |
| Consultation et changement de son propre statut par l'agent | Enregistrement et transcription des appels |
| Tableau de bord superviseur en temps réel (agents, files, appels en attente) | IA (analyse de sentiment, prédiction, callbots) |
| Générateur d'appels simulés avec trafic paramétrable | Application mobile native |
| Routage automatique des appels selon les compétences | Multi-tenant (plusieurs entreprises sur une même instance) |
| Suivi du temps d'attente et du SLA | Facturation et intégration CRM |
| Statistiques par agent, équipe, période et appel | SSO (SAML, OpenID Connect avec fournisseurs externes) |
| Historique des appels | Haute disponibilité multi-région |
| Administration des agents, équipes, compétences et files | Gestion des plannings (WFM) |
| Déploiement conteneurisé, CI/CD, supervision technique | Omnicanal (chat, e-mail, réseaux sociaux) |

### 3.2 Hypothèses

- **Appels simulés :** tous les appels proviennent du générateur de trafic. Des profils de trafic réalistes suffisent pour valider le routage, le SLA et les tableaux de bord.
- **Un seul centre d'appels :** une instance sert une seule organisation (pas de multi-tenant).
- **Comptes créés par l'administrateur :** il n'y a pas d'inscription libre. Seul l'administrateur crée les comptes et attribue les rôles.
- **Volumétrie nominale :** environ 100 agents connectés simultanément et quelques milliers d'appels par jour.
- **Environnement :** l'ensemble tourne sur un poste de développement (Windows + Docker Desktop) et sur un cluster Kubernetes local (kind/k3s).
- **Équipe :** une seule développeuse, environ 5 jours par semaine pendant 12 semaines.
- **Accès :** navigateur web récent sur poste de travail.

## 4. Exigences fonctionnelles

Priorités MoSCoW : **Must** (indispensable au MVP), **Should** (important, à livrer si possible), **Could** (souhaitable, si le temps le permet), **Won't** (écarté pour ce projet, conservé pour mémoire).

> Les règles métier détaillées (transitions de statut, algorithme de routage, définition exacte du SLA) sont précisées en section 7.

### 4.1 Authentification et comptes

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-01 | L'utilisateur se connecte avec son e-mail et son mot de passe. | Must | Avec des identifiants valides, l'utilisateur accède à l'écran de son rôle ; avec des identifiants invalides, un message d'erreur s'affiche et aucun accès n'est donné. |
| BF-02 | L'utilisateur se déconnecte. Pour un agent « En communication », la déconnexion ne prend effet sur son statut qu'à la fin de l'appel. | Must | Après déconnexion, l'accès à une page protégée redirige vers l'écran de connexion ; un agent qui se déconnecte pendant un appel reste « En communication » jusqu'à la fin de l'appel, puis passe « Hors ligne ». |
| BF-03 | L'administrateur crée, modifie et désactive des comptes utilisateurs, et leur attribue un rôle (Agent, Superviseur, Administrateur). Un compte agent nouvellement créé a le statut « Hors ligne ». | Must | Un compte créé peut se connecter avec le rôle attribué ; un compte désactivé ne peut plus se connecter ; un agent nouvellement créé apparaît « Hors ligne ». |
| BF-04 | Chaque fonctionnalité n'est accessible qu'aux rôles autorisés. | Must | Un agent qui tente d'ouvrir le tableau de bord superviseur ou l'administration reçoit un refus d'accès. |
| BF-05 | L'utilisateur modifie son propre mot de passe. | Should | Après modification, l'ancien mot de passe est refusé et le nouveau est accepté. |
| BF-06 | Le compte est verrouillé temporairement après plusieurs échecs de connexion consécutifs. | Could | Après le nombre d'échecs défini, la connexion est refusée même avec le bon mot de passe, pendant la durée définie. |

### 4.2 Agents et statuts

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-07 | L'agent voit en permanence son statut actuel. | Must | Le statut affiché sur l'écran agent correspond au statut enregistré côté serveur. |
| BF-08 | L'agent change son statut parmi « Disponible », « En pause » et « Hors ligne » en un clic. | Must | Un clic sur un statut le met à jour, et le changement est visible côté superviseur. |
| BF-09 | Le statut « En communication » est attribué automatiquement quand un appel est affecté à l'agent, puis retiré à la fin de l'appel. | Must | Lorsqu'un appel simulé est affecté, l'agent passe en « En communication » sans action de sa part ; à la fin de l'appel, il revient au statut défini par les règles métier. |
| BF-10 | L'agent voit les informations de l'appel en cours (file, temps d'attente du client). | Should | Pendant un appel, l'écran agent affiche la file et le temps d'attente de l'appel affecté. |
| BF-11 | L'agent indique un motif de pause (repas, formation, réunion…). | Could | Le motif choisi est enregistré et visible par le superviseur. |
| BF-12 | L'administrateur gère les compétences, les équipes et l'affectation des agents à des compétences et à une équipe. | Must | Une compétence ajoutée à un agent est prise en compte par le routage dès l'appel suivant. |
| BF-46 | Statut optionnel « Après appel » (temps de traitement post-appel) entre la fin d'un appel et le retour à « Disponible ». | Could (hors MVP) | À la fin d'un appel, l'agent passe « Après appel » pendant la durée paramétrée, puis « Disponible ». |

### 4.3 Appels et files d'attente

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-13 | L'administrateur crée, modifie et supprime des files d'attente ; chaque file exige une compétence et est rattachée à une équipe. La suppression est logique (section 7.7). | Must | Une file créée apparaît dans le tableau de bord et reçoit les appels qui lui sont destinés ; seuls les agents de l'équipe rattachée peuvent en recevoir les appels ; une file supprimée ne reçoit plus d'appel et son historique reste consultable. |
| BF-14 | Le système gère plusieurs files d'attente simultanément. | Must | Avec au moins 3 files actives, chaque appel est placé dans sa file et les files sont suivies séparément. |
| BF-15 | Le générateur produit des appels simulés selon un débit et une durée moyenne paramétrables par file ; seul l'administrateur peut modifier ce paramétrage. | Must | Avec un débit configuré à N appels/minute, le nombre d'appels générés sur 10 minutes est de 10 × N ± 10 % ; un agent ou un superviseur qui tente de modifier le paramétrage reçoit un refus d'accès. |
| BF-16 | L'administrateur démarre, arrête et reparamètre le générateur sans redémarrer l'application. | Should | Une modification du débit est appliquée en moins de 10 s, sans redémarrage. |
| BF-17 | Un appel entrant est affecté automatiquement à un agent « Disponible » qui possède la compétence requise par la file. | Must | Sur un échantillon de 100 appels affectés, 100 % le sont à un agent qui a la compétence requise. |
| BF-18 | Si aucun agent compétent n'est disponible, l'appel reste en attente dans sa file jusqu'à ce qu'un agent compétent se libère. | Must | Avec 0 agent compétent disponible, l'appel reste en attente ; dès qu'un agent compétent passe « Disponible », l'appel lui est affecté. |
| BF-19 | Parmi les agents éligibles, l'agent choisi est déterminé par la stratégie de routage de la file (patron Strategy, stratégie créée par une Factory) ; la stratégie par défaut, et seule stratégie Must, est « agent inactif depuis le plus longtemps ». | Must | Une nouvelle file utilise « agent inactif depuis le plus longtemps » ; avec deux agents éligibles, l'appel est affecté à celui dont le dernier passage à « Disponible » est le plus ancien, vérifiable par un test automatisé. |
| BF-20 | Le générateur simule l'abandon d'un appel quand le client attend trop longtemps ; l'administrateur configure la patience maximale de chaque file (valeur par défaut : section 7.1). | Should | Un appel dont l'attente atteint la patience de sa file est marqué « Abandonné » et retiré de la file ; une patience modifiée par l'administrateur s'applique aux appels suivants. |
| BF-21 | Le superviseur réaffecte manuellement un appel en attente à un agent donné. | Won't | Écarté : risque de conflit avec le routage automatique. |
| BF-40 | Stratégie de routage supplémentaire « agent le plus compétent », fondée sur un niveau de compétence par agent. | Could | Avec deux agents disponibles de niveaux différents, l'appel est affecté à l'agent de niveau le plus élevé. |
| BF-41 | L'administrateur définit la priorité de chaque file, de 1 (haute) à 3 (basse) ; un agent éligible pour plusieurs files reçoit d'abord les appels de la file la plus prioritaire. | Should | Avec un seul agent disponible, éligible pour deux files de priorités 1 et 2 qui ont chacune un appel en attente, l'agent reçoit l'appel de la file de priorité 1. |
| BF-47 | Marqueur « VIP » sur un appel, qui le fait passer devant les autres appels de sa file. | Could (hors MVP) | Un appel VIP arrivé après d'autres appels de la même file leur est affecté en premier. |
| BF-48 | L'administrateur choisit pour une file une seconde stratégie de routage, « tour de rôle », à la place de la stratégie par défaut (BF-19). | Should | Deux files configurées avec des stratégies différentes répartissent les appels selon leur stratégie respective, vérifiable par un test automatisé. |

### 4.4 Supervision en temps réel

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-22 | Le tableau de bord affiche le nombre d'agents par statut (Disponible, En communication, En pause, Hors ligne). | Must | Les compteurs correspondent à l'état réel des agents à tout instant. |
| BF-23 | Le tableau de bord affiche la liste des agents avec leur statut et le temps passé dans ce statut. | Must | Chaque agent connecté apparaît avec son statut courant et une durée qui s'incrémente. |
| BF-24 | Pour chaque file, le tableau de bord affiche le nombre d'appels en attente et le temps d'attente le plus long. | Must | Les valeurs affichées correspondent à l'état des files côté serveur. |
| BF-25 | Le tableau de bord se met à jour automatiquement, sans rafraîchir la page. | Must | Un changement de statut ou un nouvel appel apparaît sans action de l'utilisateur. |
| BF-26 | Le superviseur filtre le tableau de bord par équipe et par file. | Should | Avec un filtre actif, seuls les agents et files concernés sont affichés. |
| BF-27 | Le superviseur force le statut d'un agent (par exemple « Hors ligne » pour un agent parti sans se déconnecter). | Should | Le statut forcé est appliqué et l'agent en est informé sur son écran. |
| BF-44 | L'administrateur consulte le tableau de bord et les statistiques en lecture seule. | Could | L'administrateur voit le tableau de bord et les statistiques, mais toute tentative de forcer un statut reçoit un refus d'accès. |

### 4.5 SLA

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-28 | L'administrateur définit pour chaque file une cible SLA : X % des appels décrochés en moins de Y secondes. | Must | La cible enregistrée (par exemple 80 % / 20 s) est utilisée dans le calcul de conformité de la file. |
| BF-29 | Le système calcule et affiche en temps réel le taux de conformité SLA de chaque file pour la journée en cours ; la journée est définie dans le fuseau horaire du centre, fixé par la configuration de déploiement et non modifiable dans l'application (section 7.1). | Must | Sur un jeu d'appels connu, le taux affiché est égal au taux calculé à la main. |
| BF-30 | Un indicateur de couleur signale l'état SLA de chaque file : vert si le taux est supérieur ou égal à la cible, orange s'il est en dessous de la cible d'au plus N points, rouge au-delà. N est paramétrable par file (valeur par défaut : section 7.1). | Must | Avec une cible de 80 % et N = 10 : un taux de 82 % affiche vert, 75 % affiche orange, 69 % affiche rouge. |
| BF-31 | Une notification visuelle alerte le superviseur quand une file passe au niveau rouge ; le niveau orange n'affiche que le badge (niveaux SLA : section 7.6). | Should | Le passage au rouge déclenche une notification sur le tableau de bord en moins de 1 s ; le passage à l'orange n'en déclenche aucune. |
| BF-32 | Le superviseur consulte l'historique du taux SLA par jour et par file. | Could | Pour un jour passé, le taux affiché correspond aux appels de ce jour. |
| BF-42 | En plus du taux de la journée, le système affiche le taux SLA de chaque file sur une fenêtre glissante dont la durée est paramétrable par file par l'administrateur (valeur par défaut : section 7.1). | Should | Avec une fenêtre de 30 min, le taux affiché ne prend en compte que les appels comptabilisés pendant les 30 dernières minutes. |
| BF-43 | Chaque modification d'un paramètre SLA d'une file est journalisée : auteur, horodatage, ancienne valeur, nouvelle valeur. | Should | Après une modification de la cible d'une file, le journal contient une entrée avec l'auteur, l'horodatage, l'ancienne et la nouvelle valeur. |

### 4.6 Statistiques et historique

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-33 | Chaque appel est enregistré dans un historique : date, file, agent, temps d'attente, durée, issue (traité ou abandonné). | Must | Tout appel terminé apparaît dans l'historique avec tous ces champs renseignés. |
| BF-34 | Le superviseur filtre l'historique par période, file, agent et issue. | Should | Chaque filtre ne renvoie que les appels qui correspondent. |
| BF-35 | Statistiques par agent : nombre d'appels traités, durée moyenne de traitement, taux d'occupation instantané (RG-45). | Must | Sur un jeu d'appels connu, les valeurs affichées sont égales aux valeurs calculées à la main ; le taux d'occupation est celui de RG-45 pour les statuts au moment de l'affichage. |
| BF-36 | Statistiques par équipe : mêmes indicateurs agrégés au niveau de l'équipe. | Should | L'agrégat d'une équipe est cohérent avec la somme ou la moyenne de ses agents. |
| BF-37 | Statistiques par période (jour, semaine) pour chaque file : volume, temps d'attente moyen, taux d'abandon, taux SLA. | Should | Les valeurs d'une période correspondent aux appels de cette période dans l'historique. |
| BF-38 | Export de l'historique et des statistiques au format CSV. | Won't | Écarté : n'apporte rien aux objectifs du projet. |
| BF-39 | Graphiques d'évolution (volume d'appels, temps d'attente, SLA) sur la période choisie. | Could | Les points du graphique correspondent aux valeurs du tableau de statistiques. |
| BF-45 | L'agent consulte ses propres statistiques (appels traités, durée moyenne, taux d'occupation). | Could (hors MVP) | Les valeurs affichées à l'agent sont égales à celles de BF-35 pour cet agent, et il ne voit celles d'aucun autre agent. |
| BF-49 | Taux d'occupation sur une période, calculé à partir de l'historique des statuts (RG-09) : temps « En communication » / (temps « Disponible » + temps « En communication »), par agent et par équipe. | Could | Sur un historique de statuts connu, le taux affiché est égal au taux calculé à la main, en ne comptant que la partie de chaque statut comprise dans la période. |

### 4.7 Traçabilité objectifs → exigences

| Objectif | Exigences qui le couvrent |
|----------|---------------------------|
| OBJ-01 | BF-22, BF-23, BF-24, BF-25 |
| OBJ-02 | BF-12, BF-13, BF-17, BF-18, BF-19, BF-40, BF-41, BF-47, BF-48 |
| OBJ-03 | BF-28, BF-29, BF-30, BF-31, BF-42 |
| OBJ-04 | BF-07, BF-08, BF-09, BF-27, BF-46 |
| OBJ-05 | BF-33, BF-34, BF-35, BF-36, BF-37, BF-45, BF-49 |
| OBJ-06 | BF-03, BF-12, BF-13, BF-28, BF-43, BF-44 |
| OBJ-T01 à OBJ-T06 | Couverts par les exigences non fonctionnelles (section 5) |

## 5. Exigences non fonctionnelles

Toutes les BNF sont de priorité Must, sauf les exceptions décidées au Jour 4 (voir le [Product Backlog](backlog.md), section 6) :

- **Should :** BNF-10 (scan OWASP ZAP), BNF-26 (purge à 90 jours) et BNF-31 (HTTPS en production).
- **Could :** la collecte des logs dans Loki (partie de BNF-20 ; les logs JSON avec identifiant de corrélation restent Must) et les tests Playwright cités comme méthode de vérification de BNF-01, BNF-13, BNF-24 et BNF-25 ; à défaut, BNF-01 est vérifiée par l'histogramme Prometheus, et BNF-13, BNF-24 et BNF-25 par un test manuel consigné.

Charge nominale de référence : 100 agents connectés, 5 superviseurs, générateur à 2 appels par seconde.

| ID | Domaine | Exigence mesurable | Comment la vérifier |
|----|---------|--------------------|---------------------|
| BNF-01 | Performance | Le délai entre un événement (changement de statut, nouvel appel) et son affichage sur le tableau de bord est inférieur à 1 s au 95e percentile, sous charge nominale. | Test Playwright horodatant l'événement et l'affichage ; histogramme Prometheus du délai de diffusion SignalR. |
| BNF-02 | Performance | Le temps de réponse de l'API est inférieur à 300 ms au 95e percentile, sous charge nominale. | Seuil k6 `http_req_duration: p(95)<300` dans le pipeline nocturne (non bloquant pour les push, BNF-29). |
| BNF-03 | Performance | Quand un agent éligible existe, un appel passe « Affecté » en moins de 500 ms (95e percentile). Le délai est mesuré à partir de la création de l'appel si un agent éligible est déjà « Disponible », ou à partir du passage à « Disponible » de l'agent si l'appel attendait déjà. Les appels sans agent éligible ne sont pas mesurés. | Métrique Prometheus du délai d'affectation (instant de départ défini ci-contre → passage « Affecté »), vérifiée pendant le test de charge. |
| BNF-04 | Capacité | Test de marge (5 × la charge nominale) : le système supporte 500 utilisateurs simulés simultanés pendant 10 minutes, avec un taux d'erreur inférieur à 1 % et un p95 API inférieur à 500 ms. | Scénario k6 à 500 utilisateurs virtuels dans le pipeline nocturne ; seuils `http_req_failed: rate<0.01` et `http_req_duration: p(95)<500`. |
| BNF-05 | Sécurité | Toutes les routes de l'API, sauf la connexion, les sondes de santé et `/metrics`, exigent un jeton JWT valide ; la durée de vie du jeton est au plus de 60 minutes. `/metrics` est exposé sur un port interne secondaire, non routé par l'Ingress ; dans Compose, ce port n'est pas publié ; dans Kubernetes, une NetworkPolicy n'autorise que le namespace de supervision. | Tests d'intégration : sans jeton ou avec un jeton expiré, l'API répond 401. `/metrics` est injoignable par l'Ingress, depuis le poste avec Compose et depuis un pod hors du namespace de supervision (CNI qui applique les NetworkPolicy : Calico sur kind, ou k3s). |
| BNF-06 | Sécurité | Les mots de passe sont stockés uniquement sous forme hachée et salée (PBKDF2 via ASP.NET Core Identity, ou bcrypt). | Test d'intégration vérifiant qu'aucun mot de passe en clair n'est présent en base ; revue de code. |
| BNF-07 | Sécurité | Le contrôle d'accès est fondé sur les rôles (RBAC) : chaque route déclare les rôles autorisés, et un rôle non autorisé reçoit 403. | Matrice de tests automatisés rôle × route : 100 % des routes couvertes. |
| BNF-08 | Sécurité | Aucun secret (mot de passe, clé, jeton) n'est présent dans le dépôt Git. | Étape gitleaks dans le pipeline : 0 détection, sinon le pipeline échoue. |
| BNF-09 | Sécurité | Les images Docker ne contiennent aucune vulnérabilité de sévérité critique. | Scan Trivy dans le pipeline avec `--severity CRITICAL --exit-code 1`. |
| BNF-10 | Sécurité | L'application déployée ne présente aucune alerte de risque élevé au scan OWASP ZAP. | Scan ZAP baseline dans le pipeline : 0 alerte « High ». |
| BNF-11 | Disponibilité | Après un arrêt brutal, l'API redémarre automatiquement et redevient opérationnelle en moins de 30 s, sans intervention. | `docker kill` (Compose, `restart: unless-stopped`) puis `kubectl delete pod` (Kubernetes, sonde de liveness) : chronométrer le retour à l'état sain. |
| BNF-12 | Disponibilité | L'API expose des sondes `/health/live` et `/health/ready` qui répondent en moins de 100 ms. | Test d'intégration et configuration des sondes Kubernetes. |
| BNF-13 | Disponibilité | Après une coupure réseau, le client temps réel se reconnecte automatiquement en moins de 10 s et retrouve un état à jour. | Test Playwright simulant une coupure réseau. |
| BNF-14 | Maintenabilité | Le code respecte les couches : Domain ne dépend d'aucune autre couche ; Application ne dépend ni d'Infrastructure ni d'Api. | Tests d'architecture (NetArchTest) exécutés dans le pipeline. |
| BNF-15 | Maintenabilité | La couverture de tests de la couche Domain est supérieure à 70 % des lignes. | Rapport Coverlet publié dans SonarQube ; seuil appliqué dans le pipeline. |
| BNF-16 | Maintenabilité | Chaque choix technique structurant est documenté dans un ADR. | Revue : chaque technologie de la stack apparaît dans au moins un ADR du dossier `docs/adr/`. |
| BNF-17 | Portabilité | `docker compose up` démarre tous les services (API, frontend, base, générateur) avec un état sain en moins de 3 minutes, sans aucune étape manuelle. | Sur un clone vierge : chronométrer jusqu'à ce que `docker compose ps` affiche tous les services « healthy ». |
| BNF-18 | Portabilité | L'application se déploie sur un cluster kind ou k3s avec une seule commande `helm install`, tous les pods étant prêts en moins de 5 minutes. | `helm install` puis `kubectl wait --for=condition=Ready pods --all --timeout=300s`. |
| BNF-19 | Observabilité | L'API expose sur `/metrics` au moins : la longueur de chaque file, l'attente la plus longue, le taux SLA par file, le nombre d'agents par statut et la durée des requêtes HTTP. | Requête sur `/metrics` ; métriques visibles dans Prometheus et dans un tableau de bord Grafana versionné. |
| BNF-20 | Observabilité | Les logs sont structurés (JSON), portent un identifiant de corrélation, et sont consultables dans Grafana via Loki. | Requête LogQL retrouvant tous les logs d'une requête à partir de son identifiant de corrélation. |
| BNF-21 | Observabilité | Alertmanager émet une alerte `warning` quand le niveau SLA d'une file reste orange pendant la durée W, et une alerte `critical` moins de 2 minutes après son passage au rouge ; aucune alerte au niveau vert ni « N/A » (niveaux SLA : section 7.6). | Forcer une dégradation du SLA avec le générateur jusqu'à l'orange puis au rouge, et chronométrer chaque alerte. |
| BNF-22 | Qualité du code | Chaque build de `main` passe le quality gate SonarQube : 0 nouveau bug ni vulnérabilité, duplication inférieure à 3 % et couverture du nouveau code d'au moins 70 %. | Étape « quality gate » du pipeline Jenkins : le pipeline échoue si le gate échoue. |
| BNF-23 | Qualité du code | Le code frontend et backend ne comporte aucune erreur de lint ni aucun avertissement de compilation. | `npm run lint` (ESLint) et `dotnet build -warnaserror` dans le pipeline. |
| BNF-24 | Compatibilité | L'interface fonctionne sur les deux dernières versions de Chrome, Edge et Firefox, pour une résolution d'au moins 1366 × 768. | Tests Playwright exécutés sur Chromium et Firefox. |
| BNF-25 | Utilisabilité | L'interface est entièrement en français. | Revue des écrans : aucun libellé visible en anglais ; tests Playwright fondés sur les libellés français. |
| BNF-26 | Données | L'historique des appels est conservé 90 jours ; au-delà, les appels sont purgés automatiquement. | Test d'intégration : un appel daté de 91 jours est supprimé par la tâche de purge, un appel daté de 89 jours est conservé. |
| BNF-27 | Observabilité | Alertmanager émet une alerte si l'API est injoignable pendant plus de 1 minute. | Règle Prometheus `up{job="api"} == 0` avec `for: 1m` ; arrêter l'API pendant 2 minutes (`docker stop` ou mise à l'échelle à 0 réplica) : l'alerte est émise ; l'arrêter 30 s : aucune alerte. |
| BNF-28 | Données | Tous les horodatages sont enregistrés en UTC (type PostgreSQL `timestamptz`). | Test d'intégration : un horodatage écrit puis relu depuis une session configurée dans un autre fuseau désigne le même instant ; revue du schéma : aucune colonne `timestamp` sans fuseau. |
| BNF-29 | Livraison continue | Un push sur `main` déclenche automatiquement le build, les tests et le déploiement sur l'environnement de test, terminés en moins de 15 minutes ; le pipeline d'une pull request (build, tests, analyses) se termine en moins de 10 minutes ; les tests de charge k6 s'exécutent dans un pipeline nocturne et ne bloquent pas les push. | Horodater le push et la fin du déploiement (release Helm de l'environnement de test saine, ou application ArgoCD synchronisée et saine si ArgoCD est livré) ; horodater le début et la fin du pipeline d'une pull request ; le pipeline échoue si une étape échoue. |
| BNF-30 | Livraison continue | Une version déployée peut être remplacée par la version précédente en moins de 5 minutes avec `helm rollback` (OBJ-T02, LIV-12). | Déployer v2 puis revenir à v1 avec `helm rollback` : chronométrer jusqu'à ce que v1 soit saine. |
| BNF-31 | Sécurité | En production, le trafic est servi en HTTPS avec un certificat valide, et une requête HTTP est redirigée vers HTTPS (OBJ-T02, LIV-12). | `curl` en HTTPS réussit sans `--insecure` (certificat émis par cert-manager, autorité locale reconnue par le poste) ; une requête HTTP reçoit une redirection vers HTTPS. |

## 6. Acteurs

### 6.1 Description

| Acteur | Type | Description |
|--------|------|-------------|
| Agent | Humain | Conseiller qui traite les appels. Il se connecte, gère son propre statut (Disponible, En pause, Hors ligne) et reçoit automatiquement les appels qui correspondent à ses compétences et à son équipe. Persona : Yassine. |
| Superviseur | Humain | Responsable qui pilote l'activité en temps réel. Il voit tous les agents et toutes les files, quelle que soit l'équipe (filtrables par équipe et par file, BF-26), suit le SLA, consulte statistiques et historique, et peut forcer le statut d'un agent (BF-27, RG-08). Persona : Sara. |
| Administrateur | Humain | Gère les comptes, les rôles, les équipes, les compétences, les files, les stratégies de routage, les cibles SLA et le générateur de trafic. S'il est livré (BF-44, Could), il consulte le tableau de bord et les statistiques en lecture seule, pour vérifier l'effet de sa configuration. Persona : Karim. |
| Système | Automatique | Composants internes, sans compte utilisateur ni interface : le **générateur de trafic** crée les appels simulés ; le **dispatcher** affecte les appels, gère le statut « En communication », termine les appels simulés et marque les abandons. |

### 6.2 Matrice des droits

Légende : **Oui** = autorisé ; **Non** = refusé (403, BNF-07) ; **Could** = autorisé seulement si l'exigence Could citée est livrée, sinon refusé (403) ; **—** = sans objet pour cet acteur.

| Fonctionnalité | Agent | Superviseur | Administrateur | Système | Réf. |
|----------------|:-----:|:-----------:|:--------------:|:-------:|------|
| Se connecter, se déconnecter | Oui | Oui | Oui | — | BF-01, BF-02 |
| Modifier son propre mot de passe | Oui | Oui | Oui | — | BF-05 |
| Voir son propre statut | Oui | — | — | — | BF-07 |
| Changer son propre statut (Disponible, En pause, Hors ligne) | Oui | — | — | — | BF-08, RG-03 |
| Voir l'appel en cours qui lui est affecté | Oui | — | — | — | BF-10 |
| Forcer le statut d'un agent | Non | Oui (RG-08) | Non | — | BF-27 |
| Mettre un agent « En communication » ou l'en sortir | Non | Non | Non | Oui (seul) | BF-09, RG-04, RG-05 |
| Voir le statut de tous les agents | Non | Oui | Could (lecture seule, BF-44) | — | BF-22, BF-23, BF-44 |
| Voir les files et les appels en attente | Non | Oui | Could (lecture seule, BF-44) | — | BF-24, BF-44 |
| Tableau de bord temps réel (dont SLA) | Non | Oui | Could (lecture seule, BF-44) | — | BF-04, BF-22 à BF-26, BF-29 à BF-31, BF-44 |
| Statistiques et historique : les siennes | Non (BF-45, Could hors MVP) | — | — | — | BF-45 |
| Statistiques et historique : de son équipe | Non | Oui | Could (lecture seule, BF-44) | — | BF-35, BF-36, BF-44 |
| Statistiques et historique : de tous | Non | Oui | Could (lecture seule, BF-44) | — | BF-32 à BF-37, BF-44 |
| Gérer les comptes et les rôles | Non | Non | Oui | — | BF-03 |
| Gérer les équipes, les compétences et l'affectation des agents | Non | Non | Oui | — | BF-12 |
| Configurer les files (compétence, équipe, priorité, patience), les stratégies et le SLA | Non | Non | Oui | — | BF-13, BF-19, BF-28, BF-41, BF-42, BF-48, section 7.1 |
| Paramétrer, démarrer et arrêter le générateur | Non | Non | Oui | — | BF-15, BF-16 |
| Créer des appels simulés | Non | Non | Non | Oui (générateur) | BF-15 |
| Affecter les appels | Non | Non | Non | Oui (dispatcher) | BF-17, BF-21 (Won't) |
| Marquer un appel « Abandonné » | Non | Non | Non | Oui (dispatcher) | BF-20, RG-15 |

## 7. Règles métier

Chaque règle (RG) est une phrase vérifiable par au moins un test automatisé : un test unitaire de la couche Domain, avec une horloge injectable pour rendre les durées déterministes, sauf mention contraire dans la règle. La colonne « BF liées » indique les exigences (BF ou BNF) que la règle précise.

### 7.1 Paramètres de référence

Les valeurs par défaut sont définies **uniquement ici** ; les règles y font référence par leur symbole. Attention à ne pas confondre **N**, une largeur exprimée en points de pourcentage, et **F**, une durée exprimée en minutes.

| Symbole | Paramètre | Valeur par défaut | Portée | Modifiable par |
|---------|-----------|-------------------|--------|----------------|
| T | Seuil SLA : attente maximale pour qu'un appel soit « décroché dans le seuil » | 20 s | Par file | Administrateur |
| O | Objectif SLA | 80 % | Par file | Administrateur |
| N | Largeur de la zone orange sous l'objectif | 10 points | Par file | Administrateur |
| P | Patience maximale d'un appel en attente avant abandon | 120 s | Par file | Administrateur |
| F | Fenêtre glissante du taux SLA | 30 min | Par file | Administrateur |
| W | Durée en continu au niveau orange avant l'alerte `warning` | 5 min | Globale | Non (règle d'alerte versionnée) |
| R | Intervalle maximal du cycle de sécurité qui réévalue les appels en attente | 1 s | Globale | Non (constante technique) |
| Z | Fuseau horaire du centre, qui définit la journée SLA | Europe/Paris | Globale | Configuration de déploiement (non modifiable dans l'application) |
| PRIO | Priorité de la file (1 = haute, 3 = basse) | 2 | Par file | Administrateur |
| STRAT | Stratégie de routage | Agent inactif depuis le plus longtemps | Par file | Administrateur |

### 7.2 Statuts des agents

| Statut | Signification | Éligible au routage |
|--------|---------------|:-------------------:|
| Disponible | L'agent attend un appel. | Oui |
| En communication | Un appel lui est affecté et n'est pas terminé. | Non |
| En pause | L'agent est présent mais ne prend pas d'appel. | Non |
| Hors ligne | L'agent n'est pas en service. | Non |

**Table des transitions** (ligne = statut de départ, colonne = statut d'arrivée ; chaque case indique les acteurs autorisés, ou le code de refus) :

| De \ Vers | Disponible | En communication | En pause | Hors ligne |
|-----------|------------|------------------|----------|------------|
| **Disponible** | Refusée : `STATUT_IDENTIQUE` | Système (affectation d'un appel) | Agent, Superviseur | Agent, Superviseur, Système (RG-07) |
| **En communication** | Système (fin d'appel, RG-06) | Refusée : `STATUT_IDENTIQUE` | Refusée : `TRANSITION_INVALIDE` | Système (fin d'appel avec déconnexion en attente, RG-07) |
| **En pause** | Agent, Superviseur | Refusée : `TRANSITION_INVALIDE` | Refusée : `STATUT_IDENTIQUE` | Agent, Superviseur, Système (RG-07) |
| **Hors ligne** | Agent | Refusée : `TRANSITION_INVALIDE` | Agent | Refusée : `STATUT_IDENTIQUE` |

**Ordre d'évaluation d'une demande** (le premier cas qui s'applique donne le code renvoyé) :

1. L'agent est « En communication » et l'acteur n'est pas le Système → `APPEL_EN_COURS`.
2. Le statut demandé est le statut courant → `STATUT_IDENTIQUE`.
3. La case est « Refusée » → `TRANSITION_INVALIDE`.
4. L'acteur ne figure pas dans la case → `ACTEUR_NON_AUTORISE`.
5. Sinon, la transition est acceptée.

| ID | Règle | BF liées |
|----|-------|----------|
| RG-01 | À tout instant, un agent a exactement un statut parmi les quatre statuts de la section 7.2. | BF-07, BF-22 |
| RG-02 | Un compte agent nouvellement créé est « Hors ligne », et un agent qui se connecte reste « Hors ligne » jusqu'à ce qu'il choisisse un autre statut. | BF-03 |
| RG-03 | Un changement de statut n'est accepté que s'il figure dans la table des transitions pour l'acteur qui le demande ; sinon il est refusé avec le code donné par l'ordre d'évaluation, et le statut reste inchangé. | BF-08, BF-27 |
| RG-04 | Seul le Système fait passer un agent à « En communication », et uniquement au moment où un appel lui est affecté. | BF-09 |
| RG-05 | Un agent « En communication » ne quitte ce statut que lorsque son appel passe à « Terminé » ; toute demande d'un agent ou d'un superviseur pendant l'appel est refusée avec `APPEL_EN_COURS`. | BF-09, BF-27 |
| RG-06 | Quand l'appel d'un agent passe à « Terminé », le Système le remet « Disponible », sauf si une déconnexion est en attente (RG-07). | BF-09 |
| RG-07 | À la déconnexion d'un agent ou à la désactivation de son compte, le Système le passe immédiatement « Hors ligne » ; s'il est « En communication », la déconnexion est mise en attente et il passe « Hors ligne » à la fin de l'appel au lieu de « Disponible ». | BF-02, BF-03 |
| RG-08 | Un superviseur peut faire passer un agent « Disponible » ou « En pause » à « Disponible », « En pause » ou « Hors ligne » ; il ne peut ni sortir un agent de « Hors ligne » ou de « En communication », ni le mettre « En communication ». | BF-27 |
| RG-09 | Chaque changement de statut accepté est enregistré avec l'agent, l'ancien statut, le nouveau statut, l'acteur et l'horodatage UTC ; un changement refusé n'est pas enregistré. | BF-19, BF-23 |
| RG-10 | La durée passée dans le statut courant est calculée à partir de l'horodatage du dernier changement accepté ; un refus `STATUT_IDENTIQUE` ne la remet donc pas à zéro. | BF-23, BF-19 |

> **Évolution Could (BF-46), non implémentée dans le MVP :** un statut « Après appel » (temps de traitement post-appel). La transition deviendrait En communication → Après appel → Disponible après une durée paramétrable. Tant qu'il n'est pas retenu, RG-06 s'applique.

### 7.3 Cycle de vie d'un appel

| De | Vers | Déclencheur | Acteur |
|----|------|-------------|--------|
| (création) | En attente | Le générateur crée l'appel. | Système |
| En attente | Affecté | Le dispatcher choisit un agent éligible. | Système |
| Affecté | En cours | Immédiatement après l'affectation (instant de décroché). | Système |
| En cours | Terminé | La durée simulée de l'appel est écoulée. | Système |
| En attente | Abandonné | L'attente atteint la patience P de la file. | Système |

| ID | Règle | BF liées |
|----|-------|----------|
| RG-11 | Un appel ne suit que les transitions de la table 7.3 ; « Terminé » et « Abandonné » sont des états finaux, et toute autre transition est refusée. | BF-17, BF-20, BF-33 |
| RG-12 | Un appel créé par le générateur appartient à une seule file, sa compétence requise est celle de cette file, et son instant d'arrivée est celui de son passage « En attente ». | BF-13, BF-15 |
| RG-13 | Un appel passe « En cours » dans le même traitement que son affectation ; l'instant de ce passage est l'instant de décroché utilisé pour le SLA. | BF-09, BF-29 |
| RG-14 | Un appel « En cours » passe « Terminé » dès que sa durée simulée est écoulée. | BF-09, BF-15 |
| RG-15 | Un appel « En attente » dont l'attente atteint la patience P de sa file passe « Abandonné » et sort de la file ; dans un même cycle du dispatcher, les abandons sont traités avant les affectations. | BF-20 (patience par file) |
| RG-16 | Le temps d'attente d'un appel est la durée entre son instant d'arrivée et son instant de décroché ou d'abandon (ou l'instant présent s'il est encore « En attente »). | BF-24, BF-33 |
| RG-17 | Tout appel qui atteint un état final est enregistré dans l'historique avec tous les champs de BF-33. | BF-33 |

### 7.4 Routage

Chaque stratégie est une implémentation du patron Strategy ; la stratégie d'une file est créée par une Factory à partir de sa configuration (STRAT), ce qui permet de tester chaque stratégie isolément.

| ID | Règle | BF liées |
|----|-------|----------|
| RG-18 | Un agent est éligible pour un appel s'il est « Disponible », s'il possède la compétence requise par la file et s'il appartient à l'équipe rattachée à la file. | BF-12, BF-13, BF-17 |
| RG-19 | Dans une même file, les appels sont affectés dans leur ordre d'arrivée (FIFO). | BF-14, BF-18 |
| RG-20 | Parmi les agents éligibles, l'agent choisi est déterminé par la stratégie de la file : « agent inactif depuis le plus longtemps » (par défaut) ou « tour de rôle ». | BF-19, BF-48 |
| RG-21 | Stratégie « agent inactif depuis le plus longtemps » : l'agent choisi est celui dont le dernier passage à « Disponible » (RG-09) est le plus ancien. | BF-19 |
| RG-22 | Stratégie « tour de rôle » : les agents éligibles sont triés par identifiant croissant, et l'agent choisi est le premier dont l'identifiant est strictement supérieur à celui du dernier agent servi par cette file ; s'il n'y en a pas, ou si la file n'a encore servi personne, c'est le premier de la liste. | BF-48 |
| RG-23 | En cas d'égalité entre plusieurs agents dans une stratégie, l'agent qui a le plus petit identifiant est choisi. | BF-19, BF-48 |
| RG-24 | L'affectation est déclenchée par événement (appel mis en attente, agent qui passe « Disponible », changement de compétence ou d'équipe), et un cycle de sécurité réévalue en plus tous les appels en attente au moins toutes les R ; sans agent éligible, l'appel reste « En attente » dans sa file. | BF-18, BNF-03 |
| RG-25 | Un agent ne se voit jamais affecter plus d'un appel à la fois. | BF-09, BF-17 |
| RG-37 | Même quand plusieurs déclenchements du dispatcher sont simultanés (événements et cycle de sécurité), un appel n'est affecté qu'une seule fois et un agent n'est engagé que sur un seul appel ; vérifié par un test de concurrence qui lance des affectations en parallèle sur les mêmes appels et les mêmes agents. | BF-09, BF-17 |

### 7.5 Priorités des files

| ID | Règle | BF liées |
|----|-------|----------|
| RG-26 | Chaque file a une priorité PRIO entière de 1 (haute) à 3 (basse) ; toute autre valeur est refusée à l'enregistrement. | BF-41 |
| RG-27 | Le dispatcher traite les appels en attente par priorité de file croissante : un agent qui se libère et qui est éligible pour plusieurs files reçoit l'appel de la file la plus prioritaire. | BF-41, BF-14 |
| RG-28 | À priorité égale, l'appel qui attend depuis le plus longtemps est traité en premier ; à instant d'arrivée identique, c'est celui de la file qui a le plus petit identifiant. | BF-41, BF-14 |

> **Évolution Could (BF-47), non implémentée dans le MVP :** un marqueur « VIP » sur un appel, qui le ferait passer devant les autres appels de sa file.

### 7.6 SLA

| ID | Règle | BF liées |
|----|-------|----------|
| RG-29 | Un appel est « décroché dans le seuil » si son temps d'attente jusqu'au décroché (RG-16) est strictement inférieur au seuil T de sa file. | BF-28 |
| RG-30 | Les appels comptabilisés d'une période sont les appels de la file décrochés ou abandonnés pendant cette période ; les appels encore « En attente » ne sont pas comptés. | BF-29 |
| RG-31 | Convention : un appel abandonné compte toujours dans les appels comptabilisés et jamais dans les appels décrochés dans le seuil, quel que soit son temps d'attente. | BF-20, BF-29 |
| RG-32 | Taux SLA = (appels décrochés dans le seuil / appels comptabilisés) × 100. | BF-29 |
| RG-33 | Le taux est calculé sur deux périodes : la journée en cours (RG-38) et la fenêtre glissante des F dernières minutes de la file. | BF-29, BF-42 |
| RG-34 | Le niveau SLA d'une période est donné par la table des niveaux ci-dessous ; la comparaison utilise la valeur non arrondie, et l'affichage arrondit à 0,1 point. | BF-30 |
| RG-35 | Si une période ne compte aucun appel comptabilisé, le taux affiché est « N/A », l'indicateur est gris, et aucune notification ni alerte n'est émise. | BF-29, BF-30, BF-31 |
| RG-36 | La notification (BF-31) et les alertes Alertmanager (BNF-21) se fondent sur le niveau de la journée en cours ; le niveau de la fenêtre glissante est affiché avec son badge, sans notification ni alerte. | BF-31, BF-42, BNF-21 |
| RG-38 | Tous les horodatages sont enregistrés en UTC (type PostgreSQL `timestamptz`) ; la journée SLA va de 00:00 à 24:00 dans le fuseau Z du centre, convertie en UTC pour les calculs. | BNF-28, BF-29 |
| RG-39 | Au moment où un appel est comptabilisé (décroché ou abandon), le résultat « dans le seuil » ou « hors seuil » est enregistré sur l'appel avec le seuil T en vigueur à cet instant, et n'est jamais recalculé. | BF-28, BF-29 |
| RG-40 | Une modification d'un paramètre SLA ne recalcule jamais le résultat des appels déjà comptabilisés : une modification de T ne s'applique qu'aux appels comptabilisés ensuite (RG-39) ; une modification de F change immédiatement le taux affiché sur la fenêtre glissante, car l'ensemble des appels comptés change ; une modification de O ou de N ne change que le niveau affiché et les alertes, pas le taux. | BF-28, BF-30, BF-42 |
| RG-41 | Toute modification d'un paramètre SLA (T, O, N, F) est journalisée avec son auteur, son horodatage, l'ancienne valeur et la nouvelle valeur. | BF-43 |

**Niveaux SLA et alertes** (seule table de référence pour BF-30, BF-31 et BNF-21) :

| Niveau | Condition | Tableau de bord | Alertmanager |
|--------|-----------|-----------------|--------------|
| Vert | taux ≥ O | Badge vert | Aucune alerte |
| Orange | O − N ≤ taux < O | Badge orange | `warning` si le niveau reste orange en continu pendant W |
| Rouge | taux < O − N | Badge rouge et notification (BF-31) | `critical`, émise en moins de 2 minutes (BNF-21) |
| N/A | Aucun appel comptabilisé (RG-35) | Badge gris, « N/A » | Aucune alerte |

**Exemple chiffré** (file « Facturation », T = 20 s, O = 80 %, N = 10 points, journée en cours) :

| Donnée | Valeur |
|--------|--------|
| Appels décrochés | 45, dont 38 en moins de 20 s et 7 en 20 s ou plus |
| Appels abandonnés | 5 (hors seuil, RG-31) |
| Appels encore en attente | 3 (non comptés, RG-30) |
| Appels comptabilisés | 45 + 5 = 50 |
| Taux SLA | 38 / 50 × 100 = **76 %** |
| Indicateur | 70 ≤ 76 < 80 → **orange** |

Cas limites à tester : 40 / 50 = 80 % → vert (borne incluse) ; 35 / 50 = 70 % → orange (borne incluse) ; 34 / 50 = 68 % → rouge ; un appel décroché à exactement 20,0 s est hors seuil ; 0 appel comptabilisé → « N/A ».

### 7.7 Suppression d'une file

| ID | Règle | BF liées |
|----|-------|----------|
| RG-42 | La suppression d'une file qui contient des appels « En attente », « Affecté » ou « En cours » est refusée avec le code `FILE_NON_VIDE` (HTTP 409 côté API, vérifié par un test d'intégration). | BF-13 |
| RG-43 | Sinon, la suppression est logique : la file est désactivée et ses appels restent dans l'historique et dans les statistiques. | BF-13, BF-33 |
| RG-44 | Une file désactivée refuse tout nouvel appel : le générateur ne lui en crée plus, et toute création d'appel vers cette file est refusée. | BF-13, BF-15 |

### 7.8 Statistiques

| ID | Règle | BF liées |
|----|-------|----------|
| RG-45 | Le taux d'occupation est un taux instantané, calculé sur l'ensemble d'agents considéré (centre, équipe ou agent) : nombre d'agents « En communication » / (nombre d'agents « Disponible » + nombre d'agents « En communication ») × 100. Les agents « En pause » et « Hors ligne » sont exclus. Si le dénominateur vaut 0, le taux affiché est « N/A ». Pour un agent seul, il vaut donc 100 % (« En communication »), 0 % (« Disponible ») ou « N/A » (« En pause » ou « Hors ligne ») ; le taux sur une période relève de BF-49 (Could). | BF-35, BF-36 |

## 8. Contraintes

| ID | Domaine | Contrainte |
|----|---------|-----------|
| CT-01 | Technique | Stack imposée par l'[ADR-001](adr/001-choix-techniques.md) : React + TypeScript + Vite, ASP.NET Core 8 + EF Core, PostgreSQL, SignalR, Docker et Docker Compose, Jenkins (GitHub Actions en comparaison), Kubernetes (kind/k3s) + Helm, ainsi que les outils de qualité, de supervision, d'IaC et de test de l'ADR. Tout changement passe par un nouvel ADR. |
| CT-02 | Architecture | Monolithe modulaire en couches (Domain, Application, Infrastructure, Api) ; routage par le patron Strategy, stratégies créées par une Factory ; événements de domaine (Observer). |
| CT-03 | Délai | 12 semaines (60 jours ouvrés). En cas de retard, c'est le périmètre qui s'ajuste selon les priorités MoSCoW, pas le délai. |
| CT-04 | Équipe | Une seule développeuse, sans relecteur : les contrôles automatiques (tests, SonarQube, lint) remplacent la revue de code par un tiers. |
| CT-05 | Budget | Outils gratuits ou open source uniquement, aucun service cloud payant. |
| CT-06 | Matériel | Un seul poste Windows avec Docker Desktop et un cluster local kind/k3s : la RAM et le CPU sont limités, et les outils lourds (SonarQube, ArgoCD, pile de supervision) ne tournent pas forcément tous en même temps. |
| CT-07 | Fonctionnel | Appels simulés uniquement, sans aucune téléphonie réelle (section 3). |
| CT-08 | Langue | Interface en français (BNF-25) ; cahier des charges en français ; code, ADR et messages de commit en anglais. |
| CT-09 | Méthode | Git sur la branche `main`, messages au format Conventional Commits ; dépôt GitHub créé au Jour 5. |

## 9. Livrables

### 9.1 MVP (Must et Should)

| ID | Livrable | Contenu | Exigences liées |
|----|----------|---------|-----------------|
| LIV-01 | Documentation de cadrage | `VISION.md`, cahier des charges, ADR (`docs/adr/`), journal de projet | BNF-16 |
| LIV-02 | Product Backlog | Épopées, user stories, priorités MoSCoW | Sections 4 et 7 |
| LIV-03 | Code source | Backend, frontend et générateur de trafic dans le dépôt Git | Sections 4 et 7 |
| LIV-04 | Tests automatisés | Tests unitaires, d'intégration et de charge (les tests de bout en bout sont en LIV-13) | OBJ-T04, BNF-15 |
| LIV-05 | Conteneurisation | Dockerfiles et `docker-compose.yml` | OBJ-T02, BNF-17 |
| LIV-06 | Pipeline CI/CD | `Jenkinsfile`, configuration Jenkins as code, déploiement automatique sur l'environnement de test (le workflow GitHub Actions est en LIV-16) | OBJ-T01, BNF-08, BNF-09, BNF-22, BNF-29 |
| LIV-07 | Déploiement Kubernetes | Chart Helm et procédure de retour arrière (l'application ArgoCD est en LIV-14) | OBJ-T02, BNF-18, BNF-30 |
| LIV-08 | Infrastructure as code | Playbooks Ansible | OBJ-T06 |
| LIV-09 | Supervision | Configuration Prometheus, tableaux de bord Grafana versionnés, règles Alertmanager (la collecte Loki est en LIV-15) | OBJ-T03, BNF-19, BNF-21, BNF-27 |
| LIV-10 | Rapports qualité et sécurité | Rapports SonarQube, Trivy, OWASP ZAP et k6 produits par le pipeline | BNF-02, BNF-04, BNF-09, BNF-10, BNF-22 |
| LIV-11 | Documentation d'installation et d'exploitation | `README.md` : prérequis, lancement local, déploiement, retour arrière, réaction aux alertes | BNF-17, BNF-18, BNF-30 |
| LIV-12 | Démonstration finale | Démonstration de bout en bout : commit → pipeline → déploiement → métriques → alerte | Section 10, OBJ-T02, BNF-30, BNF-31 |

### 9.2 Optionnels (Could)

Livrés seulement s'il reste du temps (Product Backlog, section 6.3). Aucun critère d'acceptation global (section 10) n'en dépend.

| ID | Livrable | Contenu | Exigences liées |
|----|----------|---------|-----------------|
| LIV-13 | Tests de bout en bout | Tests Playwright sur Chromium et Firefox (partie retirée de LIV-04) | OBJ-T04, BNF-01, BNF-13, BNF-24, BNF-25 |
| LIV-14 | Déploiement GitOps | Application ArgoCD (partie retirée de LIV-07) | OBJ-T06, BNF-29 |
| LIV-15 | Collecte des logs | Loki et son agent de collecte (partie retirée de LIV-09) | OBJ-T03, BNF-20 |
| LIV-16 | Pipeline de comparaison | Workflow GitHub Actions (partie retirée de LIV-06) | CT-01 |

## 10. Critères d'acceptation globaux

Le projet est accepté lorsque chaque critère est coché (oui / non) :

- [ ] Sur un clone vierge, `docker compose up` démarre tous les services (API, frontend, base, générateur) avec un état sain, sans étape manuelle (BNF-17).
- [ ] Un changement de statut d'agent apparaît sur le tableau de bord superviseur en moins de 1 s, sans rafraîchir la page (BNF-01, BF-25).
- [ ] Un appel créé par le générateur est affecté à un agent « Disponible » qui possède la compétence requise et appartient à l'équipe de la file (RG-18, BF-17).
- [ ] Le taux SLA affiché pour une file, ainsi que sa couleur, correspondent au calcul manuel sur un jeu d'appels de test qui couvre l'exemple et les cas limites de la section 7.6 (RG-29 à RG-35, BF-29).
- [ ] Un push sur `main` déclenche automatiquement, par Jenkins et Helm, le build, les tests et le déploiement sur l'environnement de test, en moins de 15 minutes (BNF-29, US-68 du Product Backlog).
- [ ] Une API injoignable pendant plus de 1 minute (`docker stop` ou mise à l'échelle à 0 réplica) déclenche une alerte dans Alertmanager (BNF-27).

Aucun critère ne dépend d'un élément Could : sans Playwright, le critère BNF-01 se vérifie par l'histogramme Prometheus (section 5), et le déploiement ne dépend pas d'ArgoCD.

## 11. Décisions du Jour 3, confirmées au Jour 4

Écarts relevés pendant la revue de cohérence du Jour 3, et décisions prises ; elles ont été confirmées ou complétées au Jour 4 (Product Backlog). Les points 10 et 13 restent hors MVP.

| # | Point | Décision |
|---|-------|---------------------|
| 1 | Les priorités de file (RG-26 à RG-28) et la fenêtre glissante du SLA (RG-33) n'ont pas de BF dédiée en partie 1. | **Résolu :** BF-41 et BF-42 ajoutées. |
| 2 | Une réévaluation « toutes les secondes » seule ne permet pas de respecter BNF-03 (affectation en moins de 500 ms). | **Résolu :** affectation par événement avec cycle de sécurité (RG-24), absence de double affectation (RG-37), mesure définie dans BNF-03. |
| 3 | BF-31 notifie au passage au **rouge**, alors que BNF-21 alerte dès le passage **sous l'objectif** (orange). | **Résolu :** table unique des niveaux SLA et alertes (section 7.6), BF-31 et BNF-21 mises à jour. |
| 4 | Le critère « alerte si l'API est arrêtée » n'a pas de BNF, et le délai de 2 minutes est une proposition. | **Résolu :** BNF-27 (API injoignable plus de 1 minute). |
| 5 | Le fuseau horaire qui définit la « journée en cours » n'est pas spécifié (les conteneurs sont en UTC par défaut). | **Résolu :** stockage UTC et fuseau Z, Europe/Paris par défaut (RG-38). |
| 6 | Aucune BF ne permet à un agent de consulter ses propres statistiques. | **Résolu :** BF-45 (Could, hors MVP). |
| 7 | Le statut « Après appel » et le marqueur « VIP » n'ont pas de BF. | **Résolu :** BF-46 et BF-47 (Could, hors MVP). |
| 8 | « En moins de T secondes » est interprété strictement : un appel décroché à exactement T est hors seuil (RG-29). | Décision prise. |
| 9 | BF-19 ne précise pas qui configure la stratégie d'une file. | Administrateur, comme BF-13 et BF-28. |
| 10 | Un agent qui ferme son navigateur sans se déconnecter reste dans son statut : seul le forçage manuel (BF-27) le corrige. | Détection automatique hors MVP ; à évaluer. |
| 11 | BF-13 permet de supprimer une file, mais le sort de ses appels en attente n'est pas défini. | **Résolu :** refus si la file n'est pas vide, sinon suppression logique (RG-42 à RG-44). |
| 12 | Une modification de T, O ou N en cours de journée : on ne sait pas si le taux du jour est recalculé avec les nouvelles valeurs. | **Résolu :** aucun recalcul rétroactif, résultat figé sur l'appel, modifications journalisées (RG-39 à RG-41). |
| 13 | Le persona Sara gère « son » équipe, mais un superviseur voit toutes les équipes. | Cohérent grâce au filtre BF-26 ; un périmètre par équipe est hors MVP. |
| 14 | RG-41 (journal des modifications des paramètres SLA) n'a pas de BF ni de BNF source : BF-28 ne parle pas d'audit. | **Résolu :** BF-43. |
| 15 | RG-38 : le stockage des horodatages en UTC (`timestamptz`) n'a pas de BNF source ; seule la journée SLA est couverte par BF-29. | **Résolu :** BNF-28. |
| 16 | La patience P est paramétrable par file par l'administrateur (section 7.1, RG-15), mais BF-20 ne parle que d'une « patience simulée ». | **Résolu :** BF-20 complétée. |
| 17 | Le critère d'acceptation « un push sur `main` déclenche build, tests et déploiement » ne s'appuie que sur des objectifs (OBJ-T01, OBJ-T06), pas sur une BNF. | **Résolu :** BNF-29 ; durée fixée à 15 minutes au Jour 4 (point 22). |
| 18 | L'accès en lecture seule de l'administrateur au tableau de bord et aux statistiques (matrice 6.2) n'est porté par aucune BF : BF-04 ne traite que le refus opposé à l'agent. | **Résolu :** BF-44. |
| 19 | RG-02 (statut initial « Hors ligne ») et RG-07 (déconnexion différée pendant un appel) sont rattachées à BF-03, BF-08 et BF-02, mais ces BF n'énoncent pas ces comportements. | **Résolu :** BF-03 (statut initial) et BF-02 (déconnexion différée) complétées. |
| 20 | BF-19 imposait deux stratégies en Must, alors que le second algorithme figure parmi les éléments à couper en premier en cas de retard. | **Résolu (Jour 4) :** BF-19 (Must) ne garde que la stratégie par défaut « agent inactif depuis le plus longtemps » ; « tour de rôle » devient BF-48 (Should), coupée en dernier car elle démontre le patron Strategy. |
| 21 | Capacité insuffisante pour toutes les exigences Must et Should (backlog du Jour 4 : 170 points planifiés pour 154 points de capacité). | **Décision (Jour 4) :** BF-44 passe Could ; BNF-10 et BNF-26 passent Should ; Loki, Playwright et ArgoCD passent Could (section 5). Révision après le Sprint 1, avec la vélocité mesurée. |
| 22 | BNF-29 : durée `X minutes` non fixée. | **Résolu (Jour 4) :** 15 min du push au déploiement sur l'environnement de test, 10 min pour une pull request, k6 en pipeline nocturne non bloquant. |
| 23 | ArgoCD (OBJ-T06) et Playwright (OBJ-T04) sont désormais Could : ces deux objectifs ne sont plus garantis en totalité. | Accepté : déploiement automatique par Jenkins + Helm (Must) ; ArgoCD et Playwright livrés seulement s'il reste du temps. |
| 24 | Le déploiement de production avec retour arrière (Must) et HTTPS (Should) n'ont pas d'exigence source ; BNF-05 n'exempte pas `/metrics` ; le taux d'occupation (BF-35) n'a pas de formule. | **Résolu (Jour 4, revue) :** BNF-30 (retour arrière en moins de 5 minutes, Must) et BNF-31 (HTTPS, Should) ajoutées ; BNF-05 exempte `/metrics`, exposé sur un port interne secondaire non routé par l'Ingress, non publié dans Compose et protégé par une NetworkPolicy dans Kubernetes ; occupation instantanée définie par RG-45, version sur une période en BF-49 (Could). |

## 12. Historique des modifications

| Date | Version | Modification | Raison |
|------|---------|--------------|--------|
| 2026-10-08 | 0.1 | Partie 1 : sections 1 à 5 (objectifs, périmètre, BF, BNF). | Jour 2 |
| 2026-10-09 | 0.2 | Partie 2 : sections 6 à 11 ; corrections de revue (BF-41 à BF-47, BNF-27 à BNF-29, RG-37 à RG-44). | Jour 3 : revue de cohérence et de traçabilité |
| 2026-10-11 | 0.3 | BF-19 scindée (BF-48 « tour de rôle », Should) ; BF-44 Could et matrice des droits ; BNF-10 et BNF-26 Should ; Loki, Playwright et ArgoCD Could ; BNF-29 fixée à 15 min (10 min pour une pull request). | Équilibrage du Product Backlog (Jour 4) |
| 2026-10-11 | 1.0 | Section 11 renommée et point 17 clos ; livrables séparés en MVP et optionnels (LIV-13 à LIV-16) ; critère « push sur `main` » fondé sur Jenkins + Helm ; exception `/metrics` dans BNF-05 ; RG-45 (occupation instantanée) et BF-49 (occupation sur une période, Could) ; BNF-30 (retour arrière, Must) et BNF-31 (HTTPS, Should). Version figée (tag `spec-v1.0`). | Revue de fin du Jour 4 : textes obsolètes et décisions du point 24 |
