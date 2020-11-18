﻿using LoggerProblem.IOManagement.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;

namespace LoggerProblem.IOManagement
{
    public class ConsoleReader : IReader
    {
        public string ReadLine()
        {
            return Console.ReadLine();
        }
    }
}
