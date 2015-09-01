using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace Monitor
{
    struct SignalEntry
    {
        public DateTime t;
        public int x;
        public SignalEntry(DateTime t, int x)
        {
            this.t = t;
            this.x = x;
        }
    }

    class Signal
    {
        private List<SignalEntry> data;

        static private List<Brush> brushes = new List<Brush>() {
            new SolidBrush(Color.Black),    // 0 nothing
            new SolidBrush(Color.Green),   // 1 floor
            new HatchBrush(HatchStyle.LightDownwardDiagonal, Color.Red, Color.Black),  // 2 down
            new HatchBrush(HatchStyle.LightDownwardDiagonal, Color.Red, Color.Green),  // 3 floor + down
            new HatchBrush(HatchStyle.LightUpwardDiagonal, Color.Red, Color.Black),  // 4 up
            new HatchBrush(HatchStyle.LightUpwardDiagonal, Color.Red, Color.Green),  // 5 floor + up
            new HatchBrush(HatchStyle.DiagonalCross, Color.Red , Color.Black),     // 6 up + down
            new HatchBrush(HatchStyle.DiagonalCross, Color.Red , Color.Green)     // 7 all
        };

        public Signal()
        {
            data = new List<SignalEntry>();

            Brush b = 
            b = new HatchBrush(HatchStyle.DarkVertical, Color.Black, Color.White);

        }

        //public Signal(ref Graphics g): base()
        //{
        //    this.graphics  = g;
        //}

        public void Add(int value)
        {
            if (data.Count > 0)
            {
                if (data[data.Count - 1].x == value) return;
            }
            data.Add(new SignalEntry(DateTime.Now, value));
        }

        public void Trim(TimeSpan dt)
        {
            while ((data.Count > 0) && (data[0].t.Add(dt) < DateTime.Now))
            {
                data.RemoveAt(0);
            }
        }

        public void RenderBars(Graphics g, float x1, float y1, float width, float height, DateTime t1, DateTime t2)
        {
            float xx1, xx2;
            double convert = (width / ((t2 - t1).TotalSeconds));
            DateTime start, end;
            Brush b;

            for (int i = 0; i < data.Count; i++)
            {
                // adjust start
                start = data[i].t < t1 ? t1 : data[i].t;

                // find end
                end = (i == data.Count - 1) ? DateTime.Now : data[i + 1].t;

                // adjust end
                end = end > t2 ? t2 : end;

                // is there anything left?
                if (start < end)
                {
                    // convert to coords
                    xx1 = x1 + (float)(convert * (start - t1).TotalSeconds);
                    xx2 = x1 + (float)(convert * (end - t1).TotalSeconds);

                    // get brush
                    b = brushes[data[i].x & 7];

                    // draw
                    g.FillRectangle(b, xx1, y1, xx2 - xx1 - 1, height - 1);
                }
            }
        }
    }
}
