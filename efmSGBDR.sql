create database efmSGBDR2
use efmSGBDR2
create table [Service] (Num_serv bigint identity primary key, Nom_serv varchar(20), Date_creation date)
create table Employe (Matricule bigint identity primary key, Nom varchar(20), Prenom varchar(20), DateNaissance date, Adresse varchar(50),
Salaire money,Grade varchar(20), Num_serv bigint constraint fkEmployeService foreign key references [service](Num_serv))
create table Projet (Num_prj bigint identity primary key, Nom_prj varchar(20), Lieu varchar(50), nbr_limite_taches int, Num_serv bigint constraint fkProjetService foreign key references [service](Num_serv))
create table Tache (Num_tach  bigint identity primary key, Nom_tache varchar(20), date_debut date, date_fin date, cout money, Num_prj bigint constraint fkTacheProjet foreign key references Projet(Num_prj ))
create table Travaille (Matricule bigint constraint fkTravailEmploye foreign key references Employe(Matricule),Num_tach bigint constraint fkTravailTache foreign key references Tache(Num_tach), Nombre_heure int
constraint pkTravaille primary key (Matricule,Num_Tach))

create table utilisateur (login varchar(50) primary key, Nom varchar(50), Prénom varchar(50), Password varchar(50), dateExipration date, role varchar(50));
alter table utilisateur alter column password varchar(max)--Créer les requêtes de sélection (12pts):
--1.	Afficher les employés dont le nom commence avec « El », trier la liste par date de naissance. (2pts) 
select * from employe where nom like'EL%' order by DateNaissance
--2.	Afficher les noms des taches (en majuscule) qui prendrons fin ce mois ci. (2pts) 
select upper(nom_tache) from tache where DATENAME(month,date_fin)=DATENAME(month,getdate())
--3.	Compter le nombre de grades différents de l’entreprise. (2pts) 
select count(*) from (select count(grade)nb from employe group by grade)f
--4.	Afficher les employés qu’ont participé à un projet affecter à un service différent où il travaille. (2pts) 

--5.	Afficher les projets avec une tache de durée inférieure à 30jours et une autre supérieure à 60jours (Durée d’une tache = Date de Fin – date de début) (2pts) 

--6.	Afficher la masse horaire travaillée cette année (travaille débuter et terminer cette année) par projet (Masse horaire = somme (nombre_heure)) (2pts) 
--Créer les requêtes de mise à jour (4pts):
--1.	Modifier les salaires des employés selon la règle suivante : (2pts).
--o	sans modification pour les employés âgés de moins de 58 ans,
--o	augmentation de 0.5% pour les employés âgés entre 58 et 60 ans,
--o	augmentation de 5% pour les employés âgés de plus que 60 ans.

--2.	Supprimer les taches non réalisées (une tache non réalisée est une tache dont la date de fin est dépassée sans qu’elle contienne un travail) (2pts).

--Créer les checks suivants (4pts):
--1.	La date de fin de la tache ne peut pas être inférieur à la date de début(2pts).
alter table tache add constraint ckDate check(date_debut<date_fin)
--2.	L’emploiyé doit avoir 18 ans ou plus(2pts).
alter table employe add constraint ckAge check(datediff(year,DateNaissance,getdate())>=18)
--Gérer la sécurité de la base de données (6pts):
--1.	Créer le profil de connexion suivants (2pts) :
--o	CnxGestionnaire
--2.	Créer un utilisateur au niveau de la base de données gestion_projet pour le profil crée dans la question précédente (2pts)
--3.	Attribuer les autorisations suivantes a cet utilisateur (2pts) :
--o	le droit de mise à jour (insertion, modification et suppression) de toutes les tables sauf la table « employé ».
--o	le droit de consultation a toutes les tables


--Créez les fonctions  suivantes . (4 pts)
--1.	 créer la fonction getNbTache(idprojet) qui reçoit le id du projet et qui affiche le nombre de ces taches. (2pts) 
go
create function getNbTache(@id bigint)
returns int
as
begin
	declare @r int
	set @r = (select count(num_prj) from Tache where @id=Num_prj)
	return @r
end
create function nomFonction(parametr type)
returns typeRetour
as

--2.	Créer la fonction  getImportantesTache(idProjet) qui reçoit le id du projet et qui affiche 
--la liste de ses tâches les plus importante, une tâche est considérée importante lorsqu’elle fait au moins trois jours de durée. (2pts) 
create function getImportantesTache(@id bigint)
returns table
as
return select *from tache where Num_prj=@id and (datediff(day,date_debut,date_fin)>=3)


--Créez les procedures stockées suivantes . (6 pts)
--1.	Procédure nommée ps_Projet_supprimer. (2pts) 
--Permettant de supprimer en cascade un projet dont le numéro est passé en paramètre (supprimer toutes les lignes 
--correspondantes de la table travaille, tache puis projet.
--•	opération réussite : exception journalisée N°60000 (valeur de retour = 0).
--•	opération non terminée : exception journalisée avec le texte d’erreur, la date et l’utilisateur courant.
--Penser à encapsuler les requêtes dans une transaction.


create proc ps_Projet_supprimer
--2.	Procédure nommée ps_Tache_ajouter           . (2pts)              
--Accepte en paramètre le numéro de projet, le nom d’une tache, sa durée et le cout (par défaut = null), puis ajouter une ligne à la table tache.
--La procédure doit effectuer le traitement suivant :
--•	Renvoyer -1 si le numéro de projet n’existe pas.
--•	Si le numéro du projet existe, ajouter une tache tel que :
--o	numéro tache = max(num_tach)+1
--o	date_debut =
--?	s’il existe déjà une tache pour ce projet alors la date de début est : = max (date_fin ) pour le projet passé en paramètre + 1 jour
--?	si non (c’est la 1ère tache pour ce projet) la date de début est := la date d’aujourd’hui.
--•	Date_fin =date_debut +Durée (j)
--•	Si l’ajout est effectué avec succès, lever l’exception N°60000. (la procédure renvoie 0 avec le numéro de tache ajouté).
--•	Si la base de données renvoie une erreur, la procédure renvoie -2.
--3.	Procédure nommée ps_Personnel_augmenter         . (2pts)               
--Qui permet d’augmenter le salaire des trois employés les plus rentables qui ont participé à la réalisation d’un projet passé en paramètre selon la règle suivante :
--•	l’employé au 1er rang : augmentation de 2%
--•	l’employé au 2ème rang : augmentation de 1%
--•	l’employé au 3ème rang : augmentation de 0.5%
--Et de renvoyer le montant total d’augmentation.
--N.B : l’employé le plus rentable est celui qui a le plus grand taux de rendement.
--Ecrire les déclencheurs suivants: . (4pts) 
--1.	trigger nommé tg_salaire_log . (2pts) 
--o	Donner le script permettant de créer la table suivante : SalaireLog (Num_auto, matricule, date_modification, ancien_salaire, nouveau_salaire, taux, utilisateur)
--o	Créer un trigger pour ajouter une ligne dans ce log à chaque modification du salaire.
--Taux = (nouveau_salaire –ancien_salaire) / ancien_salaire.
--2.	trigger nommé tg_tache_ajouter (2pts) 
--Qui permet de contrôler le nombre des taches ajouté (le nombre des taches d’un projet doit être toujours inferieur à la valeur du champ « nbr_limite_taches »  de ce projet.




