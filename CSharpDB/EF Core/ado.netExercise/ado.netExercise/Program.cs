﻿using System;
using Microsoft.Data.SqlClient;

namespace ado.netExercise
{
    public class Program
    {
        const string connectionString = "Server=.;Integrated Security=true;Database=MinionsDB";
        public static void Main(string[] args)
        {
            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                //create DB
                //string query = "CREATE DATABASE MinionsDB";
               // ExecuteNonQuery(connection, query);

                var createTableArgs = GetCreateTableStatements();

                foreach (var query in createTableArgs)
                {
                    ExecuteNonQuery(connection, query);
                }
            }
        }

        private static void ExecuteNonQuery(SqlConnection connection, string createDB)
        {
            using var command = new SqlCommand(createDB, connection);
            var result = command.ExecuteNonQuery();
        }

        private static string[] GetCreateTableStatements()
        {
            var result = new string[]
            {
                "CREATE TABLE Countries (Id INT PRIMARY KEY IDENTITY,Name VARCHAR(50))",
                "CREATE TABLE Towns(Id INT PRIMARY KEY IDENTITY,Name VARCHAR(50), CountryCode INT FOREIGN KEY REFERENCES Countries(Id))",
                "CREATE TABLE Minions(Id INT PRIMARY KEY IDENTITY,Name VARCHAR(30), Age INT, TownId INT FOREIGN KEY REFERENCES Towns(Id))",
                "CREATE TABLE EvilnessFactors(Id INT PRIMARY KEY IDENTITY, Name VARCHAR(50))",
                "CREATE TABLE Villains (Id INT PRIMARY KEY IDENTITY, Name VARCHAR(50), EvilnessFactorId INT FOREIGN KEY REFERENCES EvilnessFactors(Id))",
                "CREATE TABLE MinionsVillains (MinionId INT FOREIGN KEY REFERENCES Minions(Id),VillainId INT FOREIGN KEY REFERENCES Villains(Id),CONSTRAINT PK_MinionsVillains PRIMARY KEY (MinionId, VillainId))"
            };

            return result;
        }

       
    }
}
