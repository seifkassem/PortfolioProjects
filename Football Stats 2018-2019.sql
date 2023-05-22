SELECT players.name, teams.name AS team, games.season, COUNT(appearances.playerID) AS appearances,
	SUM(appearances.goals) AS goals,
	SUM(appearances.assists) AS assists,
	SUM(appearances.yellowCard) AS yellowCards,
	SUM(appearances.redCard) AS redCards
FROM appearances

JOIN players ON
	appearances.playerID = players.playerID
JOIN teamstats ON
	appearances.gameID = teamstats.gameID
JOIN teams ON
	teamstats.teamID = teams.teamID
JOIN games ON
	appearances.gameID = games.gameID
WHERE (games.season = 2018 OR games.season = 2019)
	AND ((players.playerID = 1250 AND teams.teamID = 87)
	OR (players.playerID = 318 AND teams.teamID = 83)
	OR (players.playerID = 838 AND teams.teamID = 87)
	OR (players.playerID = 619 AND teams.teamID = 88)
	OR (players.playerID = 755 AND teams.teamID = 75))
GROUP BY players.name,
	teams.name,
	games.season
ORDER BY games.season