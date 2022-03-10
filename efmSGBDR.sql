create database efmSGBDR2
use efmSGBDR2
create table [Service] (Num_serv bigint identity primary key, Nom_serv varchar(20), Date_creation date)
create table Employe (Matricule bigint identity primary key, Nom varchar(20), Prenom varchar(20), DateNaissance date, Adresse varchar(50),
Salaire money,Grade varchar(20), Num_serv bigint constraint fkEmployeService foreign key references [service](Num_serv))
create table Projet (Num_prj bigint identity primary key, Nom_prj varchar(20), Lieu varchar(50), nbr_limite_taches int, Num_serv bigint constraint fkProjetService foreign key references [service](Num_serv))
create table Tache (Num_tach  bigint identity primary key, Nom_tache varchar(20), date_debut date, date_fin date, cout money, Num_prj bigint constraint fkTacheProjet foreign key references Projet(Num_prj ))
create table Travaille (Matricule bigint constraint fkTravailEmploye foreign key references Employe(Matricule),Num_tach bigint constraint fkTravailTache foreign key references Tache(Num_tach), Nombre_heure int
constraint pkTravaille primary key (Matricule,Num_Tach))

create table utilisateur (login varchar(50) primary key, Nom varchar(50), Pr�nom varchar(50), Password varchar(50), dateExipration date, role varchar(50));
alter table utilisateur alter column password varchar(max)--Cr�er les requ�tes de s�lection (12pts):
--1.	Afficher les employ�s dont le nom commence avec � El �, trier la liste par date de naissance. (2pts) 
select * from employe where nom like'EL%' order by DateNaissance
--2.	Afficher les noms des taches (en majuscule) qui prendrons fin ce mois ci. (2pts) 
select upper(nom_tache) from tache where DATENAME(month,date_fin)=DATENAME(month,getdate())
--3.	Compter le nombre de grades diff�rents de l�entreprise. (2pts) 
select count(*) from (select count(grade)nb from employe group by grade)f
--4.	Afficher les employ�s qu�ont particip� � un projet affecter � un service diff�rent o� il travaille. (2pts) 

--5.	Afficher les projets avec une tache de dur�e inf�rieure � 30jours et une autre sup�rieure � 60jours (Dur�e d�une tache = Date de Fin � date de d�but) (2pts) 

--6.	Afficher la masse horaire travaill�e cette ann�e (travaille d�buter et terminer cette ann�e) par projet (Masse horaire = somme (nombre_heure)) (2pts) 
--Cr�er les requ�tes de mise � jour (4pts):
--1.	Modifier les salaires des employ�s selon la r�gle suivante : (2pts).
--o	sans modification pour les employ�s �g�s de moins de 58 ans,
--o	augmentation de 0.5% pour les employ�s �g�s entre 58 et 60 ans,
--o	augmentation de 5% pour les employ�s �g�s de plus que 60 ans.

--2.	Supprimer les taches non r�alis�es (une tache non r�alis�e est une tache dont la date de fin est d�pass�e sans qu�elle contienne un travail) (2pts).

--Cr�er les checks suivants (4pts):
--1.	La date de fin de la tache ne peut pas �tre inf�rieur � la date de d�but(2pts).
alter table tache add constraint ckDate check(date_debut<date_fin)
--2.	L�emploiy� doit avoir 18 ans ou plus(2pts).
alter table employe add constraint ckAge check(datediff(year,DateNaissance,getdate())>=18)
--G�rer la s�curit� de la base de donn�es (6pts):
--1.	Cr�er le profil de connexion suivants (2pts) :
--o	CnxGestionnaire
--2.	Cr�er un utilisateur au niveau de la base de donn�es gestion_projet pour le profil cr�e dans la question pr�c�dente (2pts)
--3.	Attribuer les autorisations suivantes a cet utilisateur (2pts) :
--o	le droit de mise � jour (insertion, modification et suppression) de toutes les tables sauf la table � employ� �.
--o	le droit de consultation a toutes les tables


--Cr�ez les fonctions  suivantes . (4 pts)
--1.	 cr�er la fonction getNbTache(idprojet) qui re�oit le id du projet et qui affiche le nombre de ces taches. (2pts) 
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

--2.	Cr�er la fonction  getImportantesTache(idProjet) qui re�oit le id du projet et qui affiche 
--la liste de ses t�ches les plus importante, une t�che est consid�r�e importante lorsqu�elle fait au moins trois jours de dur�e. (2pts) 
create function getImportantesTache(@id bigint)
returns table
as
return select *from tache where Num_prj=@id and (datediff(day,date_debut,date_fin)>=3)


--Cr�ez les procedures stock�es suivantes . (6 pts)
--1.	Proc�dure nomm�e ps_Projet_supprimer. (2pts) 
--Permettant de supprimer en cascade un projet dont le num�ro est pass� en param�tre (supprimer toutes les lignes 
--correspondantes de la table travaille, tache puis projet.
--�	op�ration r�ussite : exception journalis�e N�60000 (valeur de retour = 0).
--�	op�ration non termin�e : exception journalis�e avec le texte d�erreur, la date et l�utilisateur courant.
--Penser � encapsuler les requ�tes dans une transaction.


create proc ps_Projet_supprimer
--2.	Proc�dure nomm�e ps_Tache_ajouter           . (2pts)              
--Accepte en param�tre le num�ro de projet, le nom d�une tache, sa dur�e et le cout (par d�faut = null), puis ajouter une ligne � la table tache.
--La proc�dure doit effectuer le traitement suivant :
--�	Renvoyer -1 si le num�ro de projet n�existe pas.
--�	Si le num�ro du projet existe, ajouter une tache tel que :
--o	num�ro tache = max(num_tach)+1
--o	date_debut =
--?	s�il existe d�j� une tache pour ce projet alors la date de d�but est : = max (date_fin ) pour le projet pass� en param�tre + 1 jour
--?	si non (c�est la 1�re tache pour ce projet) la date de d�but est := la date d�aujourd�hui.
--�	Date_fin =date_debut +Dur�e (j)
--�	Si l�ajout est effectu� avec succ�s, lever l�exception N�60000. (la proc�dure renvoie 0 avec le num�ro de tache ajout�).
--�	Si la base de donn�es renvoie une erreur, la proc�dure renvoie -2.
--3.	Proc�dure nomm�e ps_Personnel_augmenter         . (2pts)               
--Qui permet d�augmenter le salaire des trois employ�s les plus rentables qui ont particip� � la r�alisation d�un projet pass� en param�tre selon la r�gle suivante :
--�	l�employ� au 1er rang : augmentation de 2%
--�	l�employ� au 2�me rang : augmentation de 1%
--�	l�employ� au 3�me rang : augmentation de 0.5%
--Et de renvoyer le montant total d�augmentation.
--N.B : l�employ� le plus rentable est celui qui a le plus grand taux de rendement.
--Ecrire les d�clencheurs suivants: . (4pts) 
--1.	trigger nomm� tg_salaire_log . (2pts) 
--o	Donner le script permettant de cr�er la table suivante : SalaireLog (Num_auto, matricule, date_modification, ancien_salaire, nouveau_salaire, taux, utilisateur)
--o	Cr�er un trigger pour ajouter une ligne dans ce log � chaque modification du salaire.
--Taux = (nouveau_salaire �ancien_salaire) / ancien_salaire.
--2.	trigger nomm� tg_tache_ajouter (2pts) 
--Qui permet de contr�ler le nombre des taches ajout� (le nombre des taches d�un projet doit �tre toujours inferieur � la valeur du champ � nbr_limite_taches �  de ce projet.




