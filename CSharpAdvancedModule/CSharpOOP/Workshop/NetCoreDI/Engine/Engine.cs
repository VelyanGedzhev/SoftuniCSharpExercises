﻿using DummyGame.IO.Interfaces;

namespace DummyGame.Engine
{
    public class Engine
    {
        private IWriter writer;
        private IReader reader;

        public Engine(IReader reader,/* [Named(typeof(CustomConsoleWriter))]*/IWriter writer)
        {
            this.reader = reader;
            this.writer = writer;
            
        }

        public void Start()
        {
            while (true)
            {
                writer.Write("Working");
            }
        }
    }
}
