using System;
using System.Collections.Generic;
using System.Linq;
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

            //floorIndex = n;
            //label = String.Format("{0:00}", n);
            /*
            floor = false;
            up = false;
            down = false;
             */
        }

        //private int floorIndex;
        
        public bool floorCall;
        public bool downCall; 
        public bool upCall;

        public string Name { get; set; }
        public string Payer { get; set; }
    }
}

/*
 enum imageId { Down0, Down1, Up0, Up1, Floor0, Floor1, Cable, Elevator, Nothing }
        static Dictionary<imageId, string> imageFileMap = new Dictionary<imageId,string>() 
        {
            { imageId.Up0, "up"},
            { imageId.Up1, "up_on"},
            { imageId.Down0, "down"},
            { imageId.Down1, "down_on"},
            { imageId.Cable, "cable"},
            { imageId.Elevator, "elevator"},
            { imageId.Nothing, "nothing"},
            { imageId.Floor0, "floor_off"},
            { imageId.Floor1, "floor_on"},
        };
        static Dictionary<imageId, Image> imageMap = new Dictionary<imageId, Image>();
        static FloorEntry()
        {
            foreach (KeyValuePair<imageId, string> kvp in imageFileMap) 
            { 
                Image image;
                try
                {
                    image = Image.FromFile(kvp.Value + ".png");
                }
                catch (Exception e)
                {
                    image = new Bitmap(16, 16);
                }
                imageMap.Add(kvp.Key, image); 
            }
        }
   public Image goingUp
        {
            get
            {
                return imageMap[imageId.Up0];
                //return imageMap[upCall ? imageId.Up1 : imageId.Up0];
            }
        }

        public Image goingDown
        {
            get
            {
                return imageMap[imageId.Down0];
                //return imageMap[downCall ? imageId.Down1 : imageId.Down0];
            }
        }

        public Image elevator
        {
            get
            {
                if (floorIndex == elevatorPosition) return imageMap[imageId.Elevator];
                if (floorIndex > elevatorPosition) return imageMap[imageId.Cable];
                return imageMap[imageId.Nothing];
            }
        }

        public string label { get; set; }


        public Image goingHere
        {
            get
            {
                return imageMap[floorCall ? imageId.Floor1 : imageId.Floor0];
            }
        }

*/