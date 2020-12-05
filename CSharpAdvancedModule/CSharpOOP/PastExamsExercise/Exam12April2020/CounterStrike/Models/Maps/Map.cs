﻿using CounterStrike.Models.Maps.Contracts;
using CounterStrike.Models.Players;
using CounterStrike.Models.Players.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CounterStrike.Models.Maps
{
    public class Map : IMap
    {
        private List<IPlayer> terrorists;
        private List<IPlayer> counterTerrorists;

        public Map()
        {
            terrorists = new List<IPlayer>();
            counterTerrorists = new List<IPlayer>();
        }

        public string Start(ICollection<IPlayer> players)
        {
            SeparatePlayersIntoTeams(players);

            while (IsTeamAlive(terrorists) && IsTeamAlive(counterTerrorists))
            {
                AttackTeam(terrorists, counterTerrorists);
                AttackTeam(counterTerrorists, terrorists);
            }

            if (!IsTeamAlive(counterTerrorists))
            {
                return "Terrorist wins!";
            }
            else if(!IsTeamAlive(terrorists))
            {
                return "Counter Terrorist wins!";
            }

            return "Unexpected draw that should not happened!";
        }

        private bool IsTeamAlive(List<IPlayer> players)
        {
            return players.Any(p => p.IsAlive);
        }

        private void AttackTeam(List<IPlayer> attackingTeam, List<IPlayer> defendingTeam)
        {
            foreach (var attacker in attackingTeam)
            {
                if (!attacker.IsAlive) continue;

                foreach (var defender in defendingTeam)
                {
                    if (defender.IsAlive)
                    {
                        defender.TakeDamage(attacker.Gun.Fire());
                    }
                }
                
            }
        }

        private void SeparatePlayersIntoTeams(ICollection<IPlayer> players)
        {
            foreach (var player in players)
            {
                if (player is Terrorist)
                {
                    terrorists.Add(player);
                }
                else if (player is CounterTerrorist)
                {
                    counterTerrorists.Add(player);
                }
            }
        }
    }
}