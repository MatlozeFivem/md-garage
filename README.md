# MD Garage & Fourrière 🚗
:wrench:  Si vous avez le moindre problème voici notre discord https://discord.gg/NKeUfcFNrd

Un script de garage moderne et performant pour ESX avec un système de fourrière intégré.

## ✨ Fonctionnalités

- **Interface Premium** : Design moderne avec flou d'arrière-plan, animations d'entrée et icônes.
- **Multi-Garages** : 5 emplacements configurés par défaut (LS, Sandy, Paleto, Vinewood).
- **Système de Blips** : Affichage automatique de tous les garages sur la carte.
- **Images des Véhicules** : Détection intelligente des images basée sur le nom du modèle.
- **Système de Transfert** : Déplacez vos véhicules entre garages via une interface dédiée.
- **Fourrière (Impound)** : Récupérez vos véhicules perdus ou abandonnés contre des frais ($500 par défaut).
- **Support Français** : Notifications et interface entièrement en français.
- **Outils Admin** : Commande `/givecar` pour s'attribuer instantanément le véhicule dans lequel on se trouve.

## 🚀 Installation

1. **Base de données** : Exécutez le fichier `init.sql` dans votre base de données pour ajouter les colonnes nécessaires à la table `owned_vehicles`.
2. **Images** : Ajoutez vos images de véhicules au format `.png` dans `ui/img/` (ex : `adder.png`).
3. **Configuration** : Ajoutez `ensure garage` dans votre `server.cfg`.

## 🎮 Utilisation

### Pour les Joueurs
- **Point Bleu** : Ouvrir le garage pour sortir un véhicule ou le transférer.
- **Point Rouge** : Ranger le véhicule actuel (vérification de propriété incluse).
- **Fourrière** : Aller au point de remorquage (icône verte) pour récupérer les véhicules moyennant paiement.

### Pour les Admins
- Montez dans un véhicule et tapez `/givecar` pour l'ajouter à vos véhicules possédés.

## 🛠️ Configuration (client/main.lua)

Vous pouvez facilement modifier les positions, les prix et les noms dans le fichier `client/main.lua` :

```lua
local impound = {
    name = "Fourrière",
    coords = vector3(408.8, -1622.9, 29.2),
    spawn = vector4(404.9, -1632.7, 29.2, 230.0),
    price = 500 -- Modifier le prix ici
}
```

## 📋 Dépendances
- `es_extended`
- `oxmysql`


