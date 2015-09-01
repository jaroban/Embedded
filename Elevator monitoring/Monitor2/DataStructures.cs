using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;

namespace Monitor
{
    class FloorEntry
    {
        public FloorEntry(string name, string payer)
        {
            Name = name;
            Payer = payer;
        }
        
        public bool floorCall;
        public bool downCall; 
        public bool upCall;

        public string Name { get; set; }
        public string Payer { get; set; }
    }

    struct RideEntry
    {
        public DateTime t;
        public int from;
        public int to;

        public RideEntry(DateTime t, int from, int to)
        {
            this.t = t;
            this.from = from;
            this.to = to;
        }
    }
}
