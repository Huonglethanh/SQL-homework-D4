
/*Subqueries
 * Ex1: row count=  4 */

SELECT
	te2 .EventID ,
	te2 .EventName
FROM
	tblEvent te2
WHERE
	te2 .EventDate > (
	SELECT
		MAX(te.EventDate) as Last_event
	from
		tblEvent te
	left join tblCountry tc on
		te .CountryID = tc .CountryID
	WHERE
		tc .CountryID = 21);
--Ex2: row count= 16

SELECT
	te2 .EventID ,
	te2 .EventName
from
	tblEvent te2
WHERE
	len (te2.EventName)= (
	SELECT
		AVG(len (EventName))
	FROM
		tblEvent te );
--Ex3: row count=365
SELECT
	tc4.ContinentName,
	te2.EventName
FROM
	tblEvent te2
inner join tblCountry tc3 on
	te2 .CountryID = tc3 .CountryID
inner join tblContinent tc4 on
	tc4 .ContinentId = tc3 .ContinentId
WHERE
	tc4 .ContinentName in
(
	SELECT
		top 3
tc2 .ContinentName
	FROM
		tblEvent te
	inner join tblCountry tc on
		te .CountryID = tc .CountryID
	inner join tblContinent tc2 on
		tc2 . ContinentId = tc. ContinentId)
GROUP by
	tc4 .ContinentName,
	te2 .EventName
ORDER by
	COUNT(*) Asc;
--Ex4: row count= 4
SELECT
	tc .CountryName,
	count (te.EventName) as Number_of_event
FROM
	tblEvent te
inner join tblCountry tc on
	te .CountryID = tc.CountryID
GROUP by
	tc .CountryName
HAVING
	count (te.EventName) >8;


SELECT
	tc .CountryName
from
	tblCountry tc
WHERE
	(
	select
		COUNT(*) as Number_of_events
	FROM
		tblEvent te
	WHERE
		te .CountryID = tc.CountryID) >8;
--Ex5: row count=124

SELECT
	te2 .EventName
FROM
	tblEvent te2
left join tblCategory tc2 on
	te2 .CategoryID = tc2 .CategoryID
left join tblCountry tc3 on
	te2 .CountryID = tc3 .CountryID
WHERE
	tc3 .CountryID in (
	SELECT
		top 13 tc.CountryID
	FROM
		tblCountry tc
	order by
		tc.CountryName DESC)
	and tc2 .CategoryID in (
	SELECT
		top 5 tc.CategoryID
	FROM
		tblCategory tc
	order by
		tc.CategoryName DESC )
order by
	te2 .EventDate ;
--2nd solution
SELECT
	te.EventName,
	te.EventDetails
FROM
	tblEvent te
WHERE
	te .CountryID NOT IN (
	SELECT
		TOP 30 tc.CountryID
	FROM
		tblCountry tc
	ORDER BY
		tc.CountryName ASC 
	)
	and te.CategoryID NOT IN (
	SELECT
		TOP 15 tc2.CategoryID
	FROM
		tblCategory tc2
	ORDER BY
		tc2.CategoryName ASC 
	)
ORDER BY
	te.EventDate;
	--CTEs
	--Ex1:
	
with ThisAndThat as (
	SELECT
		te .EventName ,
		case
			when te.EventDetails like '%this%' then 1
			else 0
		end as If_this,
		case
			when te.EventDetails like '%that%' then 1
			else 0
		end as If_that
	FROM
		tblEvent te )
select
	TT.If_this,
	TT.If_that,
	count (*) as Number_of_event
FROM
	ThisAndThat TT
group by
	TT.If_this,
	TT.If_that;
--Query listing out events contain this and that
with ThisAndThat as (
SELECT
	te .EventName ,
	case
		when te.EventDetails like '%this%' then 1
		else 0
	end as If_this,
	case
		when te.EventDetails like '%that%' then 1
		else 0
	end as If_that
FROM
	tblEvent te )
select
	te.EventName,
	te .EventDetails
FROM
	tblEvent te
inner join ThisAndThat TT on
	te .EventName = TT.EventName
WHERE
	TT.If_that = 1
	and TT. If_this = 1;
--Ex2:
SELECT
	tc.CountryName ,
	Secondhaft_Derived. EventName
from
	(
	SELECT
		EventName ,
		CountryID
	FROM
		tblEvent te
	WHERE
		RIGHT (EventName,
		1) BETWEEN 'n' and 'z') Secondhaft_Derived
inner join tblCountry tc on
	Secondhaft_Derived.CountryID = tc .CountryID;

--Ex3: row count=4
SELECT
	te.EpisodeId ,
	td.DoctorName
FROM
	tblEpisode te
inner join tblDoctor td on
	te.DoctorId = td.DoctorId
inner join tblAuthor ta on
	ta.AuthorId = te.AuthorId
where
	ta.AuthorName like '%MP%';

with MP as (
SELECT
	te.EpisodeId ,
	td.DoctorName
FROM
	tblEpisode te
inner join tblDoctor td on
	te.DoctorId = td.DoctorId
inner join tblAuthor ta on
	ta.AuthorId = te.AuthorId
where
	ta.AuthorName like '%MP%')
SELECT
	distinct tc .CompanionName
FROM
	tblEpisodeCompanion tec
inner join MP on
	tec .EpisodeId = MP.EpisodeId
inner join tblCompanion tc on
	tc .CompanionId = tec.CompanionId ;
--Ex4:
--Step 1: row count=3
SELECT
	te.EventName ,
	te.EventDate,
	te.CountryID
FROM
	tblEvent te
WHERE
	te.EventDetails not like '%o%'
	and te.EventDetails not like '%w%'
	and te.EventDetails not like '%l%';
--step 2: row count=9
with Step1_table as (
SELECT
	te.EventName ,
	te.EventDate,
	te.CountryID,
	te.CategoryID
FROM
	tblEvent te
WHERE
	te.EventDetails not like '%o%'
	and te.EventDetails not like '%w%'
	and te.EventDetails not like '%l%')
SELECT
	te2.EventName ,
	tc.CountryName,
	te2.CategoryID ,
	te2 .CountryID
from
	tblEvent te2
right join Step1_table st on
	te2 .CountryID = st.CountryID
inner join tblCountry tc on
	te2 .CountryID = tc .CountryID;
--Step 3:

with Step1_table as (
SELECT
	te.EventName ,
	te.EventDate,
	te.CountryID,
	te.CategoryID
FROM
	tblEvent te
WHERE
	te.EventDetails not like '%o%'
	and te.EventDetails not like '%w%'
	and te.EventDetails not like '%l%')
SELECT
	DISTINCT te2.EventName ,
	tc.CountryName,
	tc2 .CategoryName,
	tc2 .CategoryID
from
	tblEvent te2
inner join Step1_table st on
	te2 .CategoryID = st.CategoryID
inner join tblCountry tc on
	te2 .CountryID = tc .CountryID
inner join tblCategory tc2 on
	tc2 .CategoryID = te2 .CategoryID
WHERE
	tc2.CategoryID = st.CategoryID
order by
	te2.EventName ASC ;
--Ex5;

with Era_Table as (
SELECT
	te.EventID ,
	CASE
		when year(EventDate)<1900 then '19th century and earlier'
		when year (EventDate)<2000 then '20th century '
		else '21st century'
	end as Era
from
	tblEvent te)
select
	Era,
	count (Era) as Number_of_event
from
	Era_Table
group by
	Era;
