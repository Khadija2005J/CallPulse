# CallPulse — Cahier des charges (partie 1)

- **Version :** 0.1 (brouillon)
- **Date :** 2026-10-08
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

> Les règles métier détaillées (transitions de statut, algorithme de routage, définition exacte du SLA) seront précisées au Jour 3 (section 7).

### 4.1 Authentification et comptes

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-01 | L'utilisateur se connecte avec son e-mail et son mot de passe. | Must | Avec des identifiants valides, l'utilisateur accède à l'écran de son rôle ; avec des identifiants invalides, un message d'erreur s'affiche et aucun accès n'est donné. |
| BF-02 | L'utilisateur se déconnecte. | Must | Après déconnexion, l'accès à une page protégée redirige vers l'écran de connexion. |
| BF-03 | L'administrateur crée, modifie et désactive des comptes utilisateurs, et leur attribue un rôle (Agent, Superviseur, Administrateur). | Must | Un compte créé peut se connecter avec le rôle attribué ; un compte désactivé ne peut plus se connecter. |
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

### 4.3 Appels et files d'attente

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-13 | L'administrateur crée, modifie et supprime des files d'attente ; chaque file exige une compétence. | Must | Une file créée apparaît dans le tableau de bord et reçoit les appels qui lui sont destinés. |
| BF-14 | Le système gère plusieurs files d'attente simultanément. | Must | Avec au moins 3 files actives, chaque appel est placé dans sa file et les files sont suivies séparément. |
| BF-15 | Le générateur produit des appels simulés selon un débit et une durée moyenne paramétrables par file ; seul l'administrateur peut modifier ce paramétrage. | Must | Avec un débit configuré à N appels/minute, le nombre d'appels générés sur 10 minutes est de 10 × N ± 10 % ; un agent ou un superviseur qui tente de modifier le paramétrage reçoit un refus d'accès. |
| BF-16 | L'administrateur démarre, arrête et reparamètre le générateur sans redémarrer l'application. | Should | Une modification du débit est appliquée en moins de 10 s, sans redémarrage. |
| BF-17 | Un appel entrant est affecté automatiquement à un agent « Disponible » qui possède la compétence requise par la file. | Must | Sur un échantillon de 100 appels affectés, 100 % le sont à un agent qui a la compétence requise. |
| BF-18 | Si aucun agent compétent n'est disponible, l'appel reste en attente dans sa file jusqu'à ce qu'un agent compétent se libère. | Must | Avec 0 agent compétent disponible, l'appel reste en attente ; dès qu'un agent compétent passe « Disponible », l'appel lui est affecté. |
| BF-19 | La stratégie de routage est configurable par file, avec deux stratégies : « agent inactif depuis le plus longtemps » (stratégie par défaut) et « tour de rôle ». | Must | Deux files configurées avec des stratégies différentes répartissent les appels selon leur stratégie respective, vérifiable par un test automatisé ; une nouvelle file utilise par défaut « agent inactif depuis le plus longtemps ». |
| BF-20 | Le générateur simule l'abandon d'un appel quand le client attend trop longtemps. | Should | Un appel dont l'attente dépasse la patience simulée est marqué « Abandonné » et retiré de la file. |
| BF-21 | Le superviseur réaffecte manuellement un appel en attente à un agent donné. | Won't | Écarté : risque de conflit avec le routage automatique. |
| BF-40 | Stratégie de routage supplémentaire « agent le plus compétent », fondée sur un niveau de compétence par agent. | Could | Avec deux agents disponibles de niveaux différents, l'appel est affecté à l'agent de niveau le plus élevé. |

### 4.4 Supervision en temps réel

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-22 | Le tableau de bord affiche le nombre d'agents par statut (Disponible, En communication, En pause, Hors ligne). | Must | Les compteurs correspondent à l'état réel des agents à tout instant. |
| BF-23 | Le tableau de bord affiche la liste des agents avec leur statut et le temps passé dans ce statut. | Must | Chaque agent connecté apparaît avec son statut courant et une durée qui s'incrémente. |
| BF-24 | Pour chaque file, le tableau de bord affiche le nombre d'appels en attente et le temps d'attente le plus long. | Must | Les valeurs affichées correspondent à l'état des files côté serveur. |
| BF-25 | Le tableau de bord se met à jour automatiquement, sans rafraîchir la page. | Must | Un changement de statut ou un nouvel appel apparaît sans action de l'utilisateur. |
| BF-26 | Le superviseur filtre le tableau de bord par équipe et par file. | Should | Avec un filtre actif, seuls les agents et files concernés sont affichés. |
| BF-27 | Le superviseur force le statut d'un agent (par exemple « Hors ligne » pour un agent parti sans se déconnecter). | Should | Le statut forcé est appliqué et l'agent en est informé sur son écran. |

### 4.5 SLA

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-28 | L'administrateur définit pour chaque file une cible SLA : X % des appels décrochés en moins de Y secondes. | Must | La cible enregistrée (par exemple 80 % / 20 s) est utilisée dans le calcul de conformité de la file. |
| BF-29 | Le système calcule et affiche en temps réel le taux de conformité SLA de chaque file pour la journée en cours. | Must | Sur un jeu d'appels connu, le taux affiché est égal au taux calculé à la main. |
| BF-30 | Un indicateur de couleur signale l'état SLA de chaque file : vert si le taux est supérieur ou égal à la cible, orange s'il est en dessous de la cible d'au plus N points, rouge au-delà. N est paramétrable par file (5 points par défaut). | Must | Avec une cible de 80 % et N = 5 : un taux de 82 % affiche vert, 77 % affiche orange, 74 % affiche rouge. |
| BF-31 | Une notification visuelle alerte le superviseur quand une file passe au rouge. | Should | Le passage au rouge déclenche une notification sur le tableau de bord en moins de 1 s. |
| BF-32 | Le superviseur consulte l'historique du taux SLA par jour et par file. | Could | Pour un jour passé, le taux affiché correspond aux appels de ce jour. |

### 4.6 Statistiques et historique

| ID | Exigence | Priorité | Critère de vérification |
|----|----------|----------|-------------------------|
| BF-33 | Chaque appel est enregistré dans un historique : date, file, agent, temps d'attente, durée, issue (traité ou abandonné). | Must | Tout appel terminé apparaît dans l'historique avec tous ces champs renseignés. |
| BF-34 | Le superviseur filtre l'historique par période, file, agent et issue. | Should | Chaque filtre ne renvoie que les appels qui correspondent. |
| BF-35 | Statistiques par agent : nombre d'appels traités, durée moyenne de traitement, taux d'occupation. | Must | Sur un jeu d'appels connu, les valeurs affichées sont égales aux valeurs calculées à la main. |
| BF-36 | Statistiques par équipe : mêmes indicateurs agrégés au niveau de l'équipe. | Should | L'agrégat d'une équipe est cohérent avec la somme ou la moyenne de ses agents. |
| BF-37 | Statistiques par période (jour, semaine) pour chaque file : volume, temps d'attente moyen, taux d'abandon, taux SLA. | Should | Les valeurs d'une période correspondent aux appels de cette période dans l'historique. |
| BF-38 | Export de l'historique et des statistiques au format CSV. | Won't | Écarté : n'apporte rien aux objectifs du projet. |
| BF-39 | Graphiques d'évolution (volume d'appels, temps d'attente, SLA) sur la période choisie. | Could | Les points du graphique correspondent aux valeurs du tableau de statistiques. |

### 4.7 Traçabilité objectifs → exigences

| Objectif | Exigences qui le couvrent |
|----------|---------------------------|
| OBJ-01 | BF-22, BF-23, BF-24, BF-25 |
| OBJ-02 | BF-12, BF-13, BF-17, BF-18, BF-19, BF-40 |
| OBJ-03 | BF-28, BF-29, BF-30, BF-31 |
| OBJ-04 | BF-07, BF-08, BF-09, BF-27 |
| OBJ-05 | BF-33, BF-34, BF-35, BF-36, BF-37 |
| OBJ-06 | BF-03, BF-12, BF-13, BF-28 |
| OBJ-T01 à OBJ-T06 | Couverts par les exigences non fonctionnelles (section 5) |

## 5. Exigences non fonctionnelles

Charge nominale de référence : 100 agents connectés, 5 superviseurs, générateur à 2 appels par seconde.

| ID | Domaine | Exigence mesurable | Comment la vérifier |
|----|---------|--------------------|---------------------|
| BNF-01 | Performance | Le délai entre un événement (changement de statut, nouvel appel) et son affichage sur le tableau de bord est inférieur à 1 s au 95e percentile, sous charge nominale. | Test Playwright horodatant l'événement et l'affichage ; histogramme Prometheus du délai de diffusion SignalR. |
| BNF-02 | Performance | Le temps de réponse de l'API est inférieur à 300 ms au 95e percentile, sous charge nominale. | Seuil k6 `http_req_duration: p(95)<300` dans le pipeline. |
| BNF-03 | Performance | Un appel est affecté en moins de 500 ms après qu'un agent compétent devient disponible (95e percentile). | Métrique Prometheus du délai d'affectation, vérifiée pendant le test de charge. |
| BNF-04 | Capacité | Test de marge (5 × la charge nominale) : le système supporte 500 utilisateurs simulés simultanés pendant 10 minutes, avec un taux d'erreur inférieur à 1 % et un p95 API inférieur à 500 ms. | Scénario k6 à 500 utilisateurs virtuels ; seuils `http_req_failed: rate<0.01` et `http_req_duration: p(95)<500`. |
| BNF-05 | Sécurité | Toutes les routes de l'API, sauf la connexion et les sondes de santé, exigent un jeton JWT valide ; la durée de vie du jeton est au plus de 60 minutes. | Tests d'intégration : sans jeton ou avec un jeton expiré, l'API répond 401. |
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
| BNF-21 | Observabilité | Une alerte est émise par Alertmanager moins de 2 minutes après que le taux SLA d'une file passe sous sa cible. | Forcer une dégradation du SLA avec le générateur et chronométrer l'alerte. |
| BNF-22 | Qualité du code | Chaque build de `main` passe le quality gate SonarQube : 0 nouveau bug ni vulnérabilité, duplication inférieure à 3 % et couverture du nouveau code d'au moins 70 %. | Étape « quality gate » du pipeline Jenkins : le pipeline échoue si le gate échoue. |
| BNF-23 | Qualité du code | Le code frontend et backend ne comporte aucune erreur de lint ni aucun avertissement de compilation. | `npm run lint` (ESLint) et `dotnet build -warnaserror` dans le pipeline. |
| BNF-24 | Compatibilité | L'interface fonctionne sur les deux dernières versions de Chrome, Edge et Firefox, pour une résolution d'au moins 1366 × 768. | Tests Playwright exécutés sur Chromium et Firefox. |
| BNF-25 | Utilisabilité | L'interface est entièrement en français. | Revue des écrans : aucun libellé visible en anglais ; tests Playwright fondés sur les libellés français. |
| BNF-26 | Données | L'historique des appels est conservé 90 jours ; au-delà, les appels sont purgés automatiquement. | Test d'intégration : un appel daté de 91 jours est supprimé par la tâche de purge, un appel daté de 89 jours est conservé. |

## 6. Acteurs

*À rédiger au Jour 3.*

## 7. Règles métier

*À rédiger au Jour 3 : transitions de statut, routage, définition du SLA.*

## 8. Contraintes

*À rédiger au Jour 3.*

## 9. Livrables

*À rédiger au Jour 3.*

## 10. Critères d'acceptation globaux

*À rédiger au Jour 3.*
