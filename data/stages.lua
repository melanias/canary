-- Minlevel and multiplier are MANDATORY
-- Maxlevel is OPTIONAL, but is considered infinite by default
-- Create a stage with minlevel 1 and no maxlevel to disable stages
experienceStages = {
	{
		minlevel = 1,
		maxlevel = 300,
		multiplier = 100
	},
	{
		minlevel = 301,
		maxlevel = 600,
		multiplier = 50
	},
	{
		minlevel = 601,
		maxlevel = 800,
		multiplier = 25
	},
	{
		minlevel = 801,
		maxlevel = 1000,
		multiplier = 20
	},
	{
		minlevel = 1001,
		maxlevel = 1100,
		multiplier = 15
	},
	{
		minlevel = 1101,
		maxlevel = 1200,
		multiplier = 10
	},
	{
		minlevel = 1201,
		maxlevel = 1300,
		multiplier = 5
	},
	{
		minlevel = 1301,
		maxlevel = 1500,
		multiplier = 3
	},
	{
		minlevel = 1501,
		multiplier = 2
	}
}

skillsStages = {
	{
		minlevel = 0,
		multiplier = 10
	}
}

magicLevelStages = {
	{
		minlevel = 0,
		multiplier = 10
	}
}
