import asyncio
import sys
import os
import random

sys.path.append(os.getcwd())

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from faker import Faker

from app.core.database import AsyncSessionLocal, engine 
from app.models.campaign import Campaign
from app.models.item import Item
from app.models.character import Character
from app.models.inventory_item import InventoryItem
from app.models.game_log import GameLog
# --- NOUVEAUX IMPORTS ---
from app.models.stat import Stat
from app.models.skill import Skill
from app.models.character_skill import CharacterSkill

fake = Faker('fr_FR')

async def seed():
    print("🌱 Début du seeding...")

    try:
        async with AsyncSessionLocal() as session:
            # ---------------------------------------------------------
            # 1. NETTOYAGE DE LA BASE DE DONNÉES
            # ---------------------------------------------------------
            print("🧹 Vidage des tables en cours (respect des contraintes clés étrangères)...")
            await session.execute(text("SET FOREIGN_KEY_CHECKS = 0;"))
            await session.execute(text("TRUNCATE TABLE character_skills")) # <-- Ajout de cette ligne
            await session.execute(text("TRUNCATE TABLE skills")) # Nouvelle table
            await session.execute(text("TRUNCATE TABLE stats"))  # Nouvelle table
            await session.execute(text("TRUNCATE TABLE inventory_items"))
            await session.execute(text("TRUNCATE TABLE characters"))
            await session.execute(text("TRUNCATE TABLE items"))
            await session.execute(text("TRUNCATE TABLE campaigns"))
            await session.execute(text("TRUNCATE TABLE game_logs"))
            await session.execute(text("SET FOREIGN_KEY_CHECKS = 1;"))
            await session.commit()
            print("✨ Tables vidées avec succès !")

           # ---------------------------------------------------------
            # 2. CRÉATION DU DICTIONNAIRE GLOBAL DES COMPÉTENCES
            # ---------------------------------------------------------
            print("📖 Création du dictionnaire global des compétences...")
            default_skills = [
                {"name": "acrobaties", "description": "Caractéristique : Dextérité. Exemples d'application : Rester debout lorsque l’équilibre est précaire ou accomplir un exercice acrobatique. https://5e-drs.fr/regles/glossaire/#acrobaties"},
                {"name": "arcanes", "description": "Caractéristique : Intelligence. Exemples d'application : Se souvenir de détails concernant des sorts, des objets magiques ou les plans d’existence. https://5e-drs.fr/regles/glossaire/#arcanes"},
                {"name": "athletisme", "description": "Caractéristique : Force. Exemples d'application : Sauter plus loin, garder la tête hors de l’eau ou briser quelque chose. https://5e-drs.fr/regles/glossaire/#athletisme"},
                {"name": "discretion", "description": "Caractéristique : Dextérité. Exemples d'application : Se soustraire à l’attention en se déplaçant sans faire de bruit et en se cachant. https://5e-drs.fr/regles/glossaire/#discretion"},
                {"name": "dressage", "description": "Caractéristique : Sagesse. Exemples d'application : Apaiser ou dresser un animal, ou lui faire adopter un certain comportement. https://5e-drs.fr/regles/glossaire/#dressage"},
                {"name": "escamotage", "description": "Caractéristique : Dextérité. Exemples d'application : Faire les poches, dissimuler un petit objet ou exécuter un tour de passe-passe. https://5e-drs.fr/regles/glossaire/#escamotage"},
                {"name": "histoire", "description": "Caractéristique : Intelligence. Exemples d'application : Se souvenir de détails historiques (événements, peuples, nations et cultures). https://5e-drs.fr/regles/glossaire/#histoire"},
                {"name": "intimidation", "description": "Caractéristique : Charisme. Exemples d'application : Impressionner ou menacer quelqu’un pour qu’il obtempère. https://5e-drs.fr/regles/glossaire/#intimidation"},
                {"name": "intuition", "description": "Caractéristique : Sagesse. Exemples d'application : Reconnaître l’humeur et les intentions des gens. https://5e-drs.fr/regles/glossaire/#intuition"},
                {"name": "investigation", "description": "Caractéristique : Intelligence. Exemples d'application : Retrouver des informations obscures ou déduire le fonctionnement des choses à partir d’indices. https://5e-drs.fr/regles/glossaire/#investigation"},
                {"name": "medecine", "description": "Caractéristique : Sagesse. Exemples d'application : Diagnostiquer une maladie ou déterminer les causes de morts récentes. https://5e-drs.fr/regles/glossaire/#medecine"},
                {"name": "nature", "description": "Caractéristique : Intelligence. Exemples d'application : Se souvenir de détails sur l’environnement, la faune, la flore et le climat. https://5e-drs.fr/regles/glossaire/#nature"},
                {"name": "perception", "description": "Caractéristique : Sagesse. Exemples d'application : Détecter ce qui peut échapper à d’autres par les sens. https://5e-drs.fr/regles/glossaire/#perception"},
                {"name": "persuasion", "description": "Caractéristique : Charisme. Exemples d'application : Convaincre autrui sans le brusquer, en toute sincérité. https://5e-drs.fr/regles/glossaire/#persuasion"},
                {"name": "religion", "description": "Caractéristique : Intelligence. Exemples d'application : Se souvenir de détails sur les dieux, les rituels religieux et les symboles sacrés. https://5e-drs.fr/regles/glossaire/#religion"},
                {"name": "representation", "description": "Caractéristique : Charisme. Exemples d'application : Jouer la comédie, jouer de la musique, conter une histoire ou danser. https://5e-drs.fr/regles/glossaire/#representation"},
                {"name": "survie", "description": "Caractéristique : Sagesse. Exemples d'application : Remonter une piste, trouver de la nourriture, s’orienter et éviter les dangers sauvages. https://5e-drs.fr/regles/glossaire/#survie"},
                {"name": "tromperie", "description": "Caractéristique : Charisme. Exemples d'application : Mentir de manière convaincante ou se déguiser sans éveiller les soupçons. https://5e-drs.fr/regles/glossaire/#tromperie"}
            ]
            
            # Stockage temporaire en mémoire pour lier facilement aux personnages ensuite
            global_skills = {}
            for s_data in default_skills:
                new_skill = Skill(name=s_data["name"], description=s_data["description"])
                session.add(new_skill)
                global_skills[s_data["name"]] = new_skill
            
            await session.flush() # On génère les ID pour les compétences globales

            # ---------------------------------------------------------
            # 3. CRÉATION DES CAMPAGNES ET PERSONNAGES
            # ---------------------------------------------------------
            # campaign = Campaign(
            #     title=f"La Fuite de Theros Obsidia",
            #     status="active",
            #     summary="Le héros tente de s'échapper des geôles d'un Légat"
            # )
            # session.add(campaign)
            # await session.flush() # Flush pour récupérer campaign.id

            # # Le personnage (plus de current_hp, stats ou skills ici, ils sont déplacés)
            # character = Character(
            #     campaign_id=campaign.id,
            #     name=f"Eren",
            #     race="Humain d'Erenland",
            #     heroic_path="Le Voilier (Passeur clandestin)",
            #     level=1
            # )
            # session.add(character)
            # await session.flush() # Crucial : on récupère character.id pour lier les stats/skills

            # # ---------------------------------------------------------
            # # 4. CRÉATION DES STATS ET SKILLS
            # # ---------------------------------------------------------
            # # Création du bloc de stats unique (One-to-One)
            # stat = Stat(
            #     character_id=character.id,
            #     strength=10,
            #     dexterity=16,
            #     constitution=12,
            #     intelligence=14,
            #     wisdom=15,
            #     charisma=12,
            #     max_hp=15,
            #     current_hp=12
            # )
            # session.add(stat)

            # # Création des compétences sous forme de liste (One-to-Many)
            # skills_data = [
            #     {"name": "perception", "level": 4, "modifier": 2},
            #     {"name": "discretion", "level": 5, "modifier": 3},
            #     {"name": "survie", "level": 3, "modifier": 1},
            #     {"name": "athletisme", "level": 2, "modifier": 0},
            #     {"name": "acrobaties", "level": 4, "modifier": 3},
            #     {"name": "intimidation", "level": 1, "modifier": -1},
            #     {"name": "persuasion", "level": 2, "modifier": 1}
            # ]

            # for skill in skills_data:
            #     linked_skill = global_skills[skill["name"]]
            #     new_skill = CharacterSkill(
            #         character_id=character.id,
            #         skill_id=linked_skill.id,
            #         level=skill["level"],
            #         modifier=skill["modifier"]
            #     )
            #     session.add(new_skill)

            # ---------------------------------------------------------
            # 4. VALIDATION FINALE
            # ---------------------------------------------------------
            await session.commit()
            print("✅ Base de données fraîchement remplie avec des données Faker et les nouvelles tables !")

    finally:
        # ---------------------------------------------------------
        # 6. EXTINCTION DU MOTEUR (Évite l'erreur Event Loop)
        # ---------------------------------------------------------
        print("🔌 Fermeture des connexions à la base de données...")
        await engine.dispose()

if __name__ == "__main__":
    asyncio.run(seed())