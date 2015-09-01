// bosky@chello.sk
// pan boskovic
// 0911 420 024

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

using System.IO;
using System.IO.Ports;
using System.Drawing.Drawing2D;
using System.Text.RegularExpressions;
using System.Collections;
using System.Globalization;

namespace Monitor
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        int floorNumber = -1;
        int liftPosition;
        byte relay1, relay2;
        byte direction;
        Random random = new Random();

        //List<Signal> signalList;
        //BindingList<FloorInfo> floorList = new BindingList<FloorInfo>();

        #region Basic I/O stuff

        ASCIIEncoding asciiEncoding = new ASCIIEncoding();
        List<byte> history = new List<byte>();
        int decoderState = 0;
        string entryName;
        byte[] entryData = new byte[1000];
        int entryBytesPerField;
        int entryFields;
        int entryByteIndex;
        int receivedBytes;

        private void portOK()
        {
            toolTip1.SetToolTip(this.label1, "OK");
            label1.Text = "OK";
            label1.BackColor = Color.LightGreen; //SystemColors.Control;
        }

        private void portError(string s)
        {
            toolTip1.SetToolTip(this.label1, s);
            label1.Text = "Error";
            label1.BackColor = Color.Red;
        }

        private void tryOpen(string s)
        {
            try
            {
                serialPort1.PortName = s;
                serialPort1.Open();
                send("debug on");
                receivedBytes = 0;
                portOK();
                Properties.Settings.Default.serialPortName = serialPort1.PortName;
            }
            catch (Exception e)
            {
                portError(e.Message);
            }
        }

        private void tryClose()
        {
            if(serialPort1.IsOpen)
            {
                serialPort1.Close();
            }
        }

        private void send(string s)
        {
            if (!serialPort1.IsOpen) return;
            try
            {
                serialPort1.Write(s);
            }
            catch (Exception e)
            {
                portError(e.Message);
            }
        }

        private void sendMsg0(char c, int id)
        {
            send(String.Format("msg0{0:x2}{1:x2}", (int)c & 255, id & 255));
        }

        private void sendMsg1(char c, int id, int d1)
        {
            send(String.Format("msg1{0:x2}{1:x2}{2:x2}", (int)c & 255, id & 255, d1 & 255));
        }

        private void sendMsg2(char c, int id, int d1, int d2)
        {
            send(String.Format("msg2{0:x2}{1:x2}{2:x2}{3:x2}", (int)c & 255, id & 255, d1 & 255, d2 & 255));
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (!serialPort1.IsOpen) return;

            byte[] data = asciiEncoding.GetBytes(serialPort1.ReadExisting());

            receivedBytes += data.Length;

            foreach (byte a in data)
            {
                history.Add(a);
                while (history.Count > 5) history.RemoveAt(0);
                if (asciiEncoding.GetString(history.ToArray()) == " <>< ")
                {
                    decoderState = 1;
                    entryName = "";
                }
                else
                {
                    switch (decoderState)
                    {
                        case 1:
                            // read null-terminated entry name
                            if (a > 0) entryName += asciiEncoding.GetString(new byte[] { a }); else decoderState = 2;
                            break;

                        case 2:
                            // type of data that follows
                            decoderState = (a < 5) ? new byte[] { 3, 4, 7, 4, 7 }[a] : 0;
                            break;

                        case 3:
                            // single byte entry
                            entryData[0] = a;
                            updateEntry();
                            decoderState = 0;
                            break;

                        case 4:
                            // multi-byte...
                            entryBytesPerField = a;
                            decoderState = (a > 0) ? 5 : 0;
                            break;

                        case 5:
                            // ...variable length array
                            entryFields = a;
                            entryByteIndex = 0;
                            decoderState = (a > 0) ? 6 : 0;
                            break;

                        case 6:
                            // store incoming data
                            entryData[entryByteIndex++] = a;
                            if (entryByteIndex >= entryFields * entryBytesPerField)
                            {
                                updateEntry();
                                decoderState = 0;
                            }
                            break;

                        case 7:
                            // single byte variable length array
                            entryBytesPerField = 1;
                            entryFields = a;
                            entryByteIndex = 0;
                            decoderState = (a > 0) ? 6 : 0;
                            break;

                        default:
                            decoderState = 0;
                            break;
                    }
                }
            }
        }

        private void timer2_Tick(object sender, EventArgs e)
        {
            if (receivedBytes == 0) send("debug on");
            receivedBytes = 0;
        }

        #endregion

        #region Updating GUI from serial port

        private bool getBit(byte a, int bit)
        {
            return (a & (1 << bit)) > 0;
        }

        private void updateEntry()
        {
            switch (entryName)
            {
                case "floors":
                    updateFloorNumber(entryData[0]);
                    break;

                case "lcds":
                    updateLCD();
                    break;

                case "lpos":
                    updateLiftPosition(entryData[0]);
                    break;

                case "lsub":
                    // ?
                    break;

                case "calls":
                    for (int i = 0; i < floorList.Count; i++)
                    {
                        byte b = entryData[i];
                        updateCall(i, b);
                    }
                    break;

                case "rele1":
                    relay1 = entryData[0];
                    bool moving = (entryData[0] & 3) != 0;
                    updateRides(moving);
                    break;

                case "rele2": 
                    relay2 = entryData[0];
                    break;

                case "smer":
                    direction = entryData[0];
                    label3.BackColor = getBit(direction, 0) ? Color.Yellow : Color.DarkGray;
                    label4.BackColor = getBit(direction, 1) ? Color.Yellow : Color.DarkGray;
                    break;
                    
                default:
                    break;
            }

            //    ElseIf entry_name = "rele1" Then
            //        h = entry_field(0)
            //        all_closed = get_bit(h, 0) Or get_bit(h, 1)
            //        If all_closed Then
            //            dax = 0
            //            dadx = 0
            //            dbx = 0
            //            dbdx = 0
            //        ElseIf get_bit(h, 4) Then ' opening
            //            dadx = 0.1
            //        ElseIf get_bit(h, 5) Then ' closing
            //            dadx = -0.1
            //        Else
            //            If dadx > 0 Then
            //                dax = 1
            //            ElseIf dadx < 0 Then
            //                dax = 0
            //            End If
            //            dadx = 0
            //        End If
            //    ElseIf entry_name = "rele2" Then
            //        h = entry_field(0)
            //        svetlo = Not get_bit(entry_field(0), 1)
            //        If all_closed Then
            //            dax = 0
            //            dadx = 0
            //            dbx = 0
            //            dbdx = 0
            //        ElseIf get_bit(h, 4) Then ' opening
            //            dbdx = 0.1
            //        ElseIf get_bit(h, 5) Then ' closing
            //            dbdx = -0.1
            //        Else
            //            If dbdx > 0 Then
            //                dbx = 1
            //            ElseIf dbdx < 0 Then
            //                dbx = 0
            //            End If
            //            dbdx = 0
            //        End If
            //    ElseIf entry_name = "errors" Then
            //        If entry_len > 0 Then
            //            For i = 1 To max_errors
            //                got_error(i) = 0
            //            Next i
            //            For i = 0 To entry_len - 1
            //                h = entry_field(i)
            //                If h > 0 And h <= max_errors Then got_error(h) = 1
            //            Next i
            //            For i = 1 To max_errors
            //                If got_error(i) = 1 And old_error(i) = 0 Then
            //                    Call add_to_history(errors(i))
            //                End If
            //                old_error(i) = got_error(i)
            //            Next i
            //        End If
          

        }

        private void updateFloorNumber(int h)
        {
            if (h >= 2 && h <= 32)
            {
                floorNumber = h;

                if (floorList.Count != floorNumber)
                {
                    while (numericUpDown1.Value > floorList.Count)
                    {
                        floorList.Insert(0, new FloorEntry("", ""));
                    }

                    while (numericUpDown1.Value < floorList.Count)
                    {
                        floorList.RemoveAt(0);
                    }
                }
            }
        }

        private void updateLiftPosition(byte a)
        {
            if (a < floorNumber)
            {
                liftPosition = a;
            }
            else if(a == 255)
            {
                liftPosition = -1;
            }

            //FloorEntry.SetElevatorPosition(liftPosition);
            //dataGridView1.Refresh();
        }

        private void updateCall(int floor, byte value)
        {
            floorList[floorList.Count - floor - 1].floorCall = getBit(value, 0);
            floorList[floorList.Count - floor - 1].downCall = getBit(value, 1);
            floorList[floorList.Count - floor - 1].upCall = getBit(value, 2);

            // add as signal
            //signalList[floor].Add(value & 7);
        }

        private void updateRides(bool moving)
        {
            if (rideState == 0)
            {
                if (moving)
                {
                    rideStart = liftPosition;
                    rideState = 1;
                }
            }
            else
            {
                if (!moving)
                {
                    rideStop = liftPosition;
                    rideState = 0;

                    // store ride
                    if (rideStart >= 0 && rideStop >= 0 && rideStart != rideStop)
                    {
                        rideList.Add(new RideEntry(DateTime.Now, rideStart, rideStop));
                        updateRideTable = true;
                        AppendToRides();
                    }
                    rideStart = -1;
                    rideStop = -1;
                }
            }
        }

        #endregion

        #region Initialization / shutdown

        private void Form1_Load(object sender, EventArgs e)
        {
            this.Height = Properties.Settings.Default.formHeight;
            this.Width = Properties.Settings.Default.formWidth;

            comboBox2.SelectedIndex = Properties.Settings.Default.rideMode;
            textBox1.Text = Properties.Settings.Default.deleteAfter.ToString();
            checkBox1.Checked = Properties.Settings.Default.deleteRides;
            tabControl1.SelectedIndex = Properties.Settings.Default.selectedTab;

            dateTimePicker1.Value = DateTime.Now;

            string[] serialPortNames = SerialPort.GetPortNames();

            comboBox1.Items.AddRange(serialPortNames);

            string s = Properties.Settings.Default.serialPortName;

            if (s != "")
            {
                comboBox1.Text = s;

                // try to open it
                tryClose();
                tryOpen(comboBox1.Text);
            }

            TextReader tr;

            try
            {
                tr = new StreamReader("floors.csv");

                // skip titles
                tr.ReadLine();

                while ((s = tr.ReadLine()) != null)
                {
                    s = s.Trim();
                    if (s == "") break;
                    string[] a = Utilities.SplitCSV(s);
                    if (a.Length >= 2)
                    {
                        floorList.Add(new FloorEntry(a[0], a[1]));
                    }
                }
                tr.Close();
            }
            catch
            {
                // hmm
            }

            numericUpDown1.Value = floorList.Count;

            // read ride list
            DateTime dt;
            int from, to;

            try
            {
                tr = new StreamReader("rides.csv");

                // skip titles
                tr.ReadLine();

                while ((s = tr.ReadLine()) != null)
                {
                    s = s.Trim();
                    if (s == "") break;
                    string[] a = Utilities.SplitCSV(s);
                    if (a.Length >= 3)
                    {
                        if (DateTime.TryParse(a[0], out dt) &&
                            Int32.TryParse(a[1], out from) &&
                            Int32.TryParse(a[2], out to))
                        {
                            rideList.Add(new RideEntry(dt, from, to));
                        }
                    }
                }
                tr.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Chyba pri načítavaní súboru rides.csv: " + ex.Message, "Chyba", MessageBoxButtons.OK);
            }

            dataGridView3.AutoGenerateColumns = true;

            /*
            DataGridViewColumn c = new DataGridViewColumn();
            c.HeaderText = "Poschodie";
            c.DataPropertyName = "Name";
            dataGridView3.Columns.Add(c);

            c = new DataGridViewColumn();
            c.HeaderText = "Firma";
            c.DataPropertyName = "Payer";
            dataGridView3.Columns.Add(c);
            */

            dataGridView3.DataSource = floorList;

            dataGridView3.Columns[0].HeaderText = "Poschodie";
            dataGridView3.Columns[1].HeaderText = "Firma";

            for (int i = 8; i < 60; i += 2)
            {
                fontList.Add(new Font("Calibri", i));
            }
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            tryClose();

            int expiration = -1;
            if (Int32.TryParse(textBox1.Text, out expiration))
            {
                Properties.Settings.Default.deleteAfter = expiration;
            }
            Properties.Settings.Default.selectedTab = tabControl1.SelectedIndex;
            Properties.Settings.Default.deleteRides = checkBox1.Checked;
            Properties.Settings.Default.formHeight = this.Height;
            Properties.Settings.Default.formWidth = this.Width;
            Properties.Settings.Default.rideMode = comboBox2.SelectedIndex;
            Properties.Settings.Default.Save();

            // store floor info
            try
            {
                TextWriter tw = new StreamWriter("floors.csv");

                tw.WriteLine("Poschodie,Firma");

                for (int i = 0; i < floorList.Count; i++)
                {
                    string s = Utilities.JoinCSV(new List<string>() 
                    { 
                        floorList[i].Name, 
                        floorList[i].Payer 
                    });
                    tw.WriteLine(s);
                }
                tw.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Chyba pri zápise do súboru: " + ex.ToString() + " " + ex.Message, "Chyba", MessageBoxButtons.OK);
            }

            // store ride info
            try
            {
                TextWriter tw = new StreamWriter("rides_new.csv");

                tw.WriteLine("Cas,Z,Do");

                for (int i = 0; i < rideList.Count; i++)
                {
                    // check expiration
                    if (checkBox1.Checked && (expiration > 0) && (rideList[i].t.AddMonths(expiration) < DateTime.Now))
                    {
                        // skip it
                        continue;
                    }

                    string s = Utilities.JoinCSV(new List<string>() 
                    { 
                        rideList[i].t.ToString(),
                        rideList[i].from.ToString(),
                        rideList[i].to.ToString()
                    });
                    tw.WriteLine(s);
                }
                tw.Close();
            
                // delete old
                File.Delete("rides_old.csv");

                // copy rides to old
                File.Move("rides.csv", "rides_old.csv");

                // replace new
                File.Move("rides_new.csv", "rides.csv");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Chyba pri zápise do súboru: " + ex.ToString() + " " + ex.Message, "Chyba", MessageBoxButtons.OK);
            }
        }

        #endregion

        #region Settings tab

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            tryClose();
            tryOpen(comboBox1.Text);
        }

        #endregion

        #region Calls (graphics / elevator) tab

        List<Font> fontList = new List<Font>();

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            Graphics g = e.Graphics;

            int nn = floorNumber;

            float ww = pictureBox1.ClientSize.Width;
            float hh = pictureBox1.ClientSize.Height;

            float ww1 = ww / 8;
            float hh1 = hh / nn;

            float square = 0.7f * Math.Min(ww1, hh1);
            float sqrt3_2 = (float)(Math.Sqrt(3) / 2);
            Pen p = new Pen(Color.Black);

            // up
            for (int i = 0; i < floorNumber; i++)
            {
                float yy = i * hh1;
                Brush b = new SolidBrush(floorList[floorNumber - i - 1].upCall ? Color.Yellow : Color.LightGray);
                g.FillRectangle(b, 0, yy, ww1, hh1);
                g.DrawLine(p, 0, yy, ww1, yy);

                // draw arrow
                float x1 = ww1 / 2 - square / 2;
                float x2 = ww1 / 2;
                float x3 = ww1 / 2 + square / 2;
                float y1 = hh1 / 2 + sqrt3_2 * square / 2;
                float y2 = hh1 / 2 - sqrt3_2 * square / 2;

                g.DrawLine(p, x1, yy + y1, x2, yy + y2);
                g.DrawLine(p, x1, yy + y1, x3, yy + y1);
                g.DrawLine(p, x2, yy + y2, x3, yy + y1);
            }

            // down
            for (int i = 0; i < floorNumber; i++)
            {
                float yy = i * hh1;
                Brush b = new SolidBrush(floorList[floorNumber - i - 1].downCall ? Color.Yellow : Color.LightGray);
                g.FillRectangle(b, ww1, yy, ww1, hh1);
                g.DrawLine(p, ww1, yy, 2 * ww1, yy);

                // draw arrow
                float x1 = ww1 / 2 - square / 2;
                float x2 = ww1 / 2;
                float x3 = ww1 / 2 + square / 2;
                float y1 = hh1 / 2 - sqrt3_2 * square / 2;
                float y2 = hh1 / 2 + sqrt3_2 * square / 2;

                g.DrawLine(p, ww1 + x1, yy + y1, ww1 + x2, yy + y2);
                g.DrawLine(p, ww1 + x1, yy + y1, ww1 + x3, yy + y1);
                g.DrawLine(p, ww1 + x2, yy + y2, ww1 + x3, yy + y1);
            }

            // floor
            Brush brush = new SolidBrush(Color.Black);

            for (int i = 0; i < floorNumber; i++)
            {
                float yy = i * hh1;
                Brush b = new SolidBrush(floorList[floorNumber - i - 1].floorCall ? Color.Yellow : Color.LightGray);
                g.FillRectangle(b, ww - ww1, yy, ww1, hh1);
                g.DrawLine(p, ww - ww1, yy, ww, yy);

                // draw floor name
                string s = floorList[i].Name;
                int j = fontList.Count - 1;
                float sww = 0, shh = 0;

                while (j >= 0)
                {
                    SizeF sizeF = g.MeasureString(s, fontList[j]);
                    sww = sizeF.Width;
                    shh = sizeF.Height;
                    if (sww < ww1 && shh < hh1) break;
                    j--;
                }
                if (j < 0) j = 0;
                g.DrawString(s, fontList[j], brush, 
                    new RectangleF(
                        ww - ww1 + (ww1 - sww) / 2, 
                        yy + (hh1 - shh) / 2, 
                        ww1, 
                        hh1
                    )
                );
            }

            // elevator
            float exx1 = 2 * ww1;
            float exx2 = ww - ww1;






            g.DrawLine(p, ww1, 0, ww1, hh - 1);
            g.DrawLine(p, 2 * ww1, 0, 2 * ww1, hh - 1);
            g.DrawLine(p, ww - ww1, 0, ww - ww1, hh - 1);

            g.DrawRectangle(p, 0, 0, ww - 1, hh - 1);
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {

        }

        private void pictureBox1_MouseDown(object sender, MouseEventArgs e)
        {
            int nn = floorNumber;

            float ww = pictureBox1.ClientSize.Width;
            float hh = pictureBox1.ClientSize.Height;

            float ww1 = ww / 8;
            float hh1 = hh / nn;

            int i = (int)Math.Floor((double)((hh - e.Y) / hh1));
            if (i < 0 || i >= floorList.Count) return;
            int hlp = floorList.Count - i - 1;

            if (0 < e.X && e.X < ww1)
            {
                if (floorList[hlp].upCall) sendMsg2('g', 3, 2, i); else sendMsg2('g', 2, 2, i);
            }
            if (ww1 < e.X && e.X < 2 * ww1)
            {
                if (floorList[hlp].downCall) sendMsg2('g', 3, 1, i); else sendMsg2('g', 2, 1, i);
            }
            if (ww - ww1 < e.X && e.X < ww)
            {
                if (floorList[hlp].floorCall) sendMsg2('g', 3, 0, i); else sendMsg2('g', 2, 0, i);
            }
        }

        #endregion

        #region Advanced (board) tab

        byte[] oldLcdData = new byte[34];

        private bool detectChange(ref byte[] a, ref byte[] old, int length)
        {
            for (int i = 0; i < length; i++)
            {
                if (old[i] != a[i]) return true;
                old[i] = a[i];
            }
            return false;
        }

        private void updateLCD()
        {
            if (!detectChange(ref entryData, ref oldLcdData, 34)) return;

            Font font1 = new Font("Courier New", 16, FontStyle.Regular);
            Font font2 = new Font("Courier New", 16, FontStyle.Underline);

            // lcd display contents
            richTextBox1.Clear();

            string s = "";
            for (int i = 0; i < 32; i++)
            {
                if (i == 16) s += System.Environment.NewLine;

                if (entryData[i] < 8)
                {
                    s += "□↓↑↕????"[entryData[i]];
                }
                else
                {
                    s += asciiEncoding.GetString(entryData, i, 1);
                }
            }

            richTextBox1.SelectionFont = font1;
            richTextBox1.Text = s;

            // cursor
            if ((entryData[32] == 6) && (entryData[33] >= 0) && (entryData[33] < 32))
            {
                richTextBox1.Select(entryData[33], 1);
                richTextBox1.SelectionFont = font2;
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            sendMsg0('c', 0);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            sendMsg0('c', 1);
        }

        private void button4_Click(object sender, EventArgs e)
        {
            sendMsg0('c', 2);
        }

        private void button5_Click(object sender, EventArgs e)
        {
            sendMsg0('c', 3);
        }

        private void button6_Click(object sender, EventArgs e)
        {
            sendMsg0('c', 4);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            send("reset");
        }

        int resetCounter;

        private void button8_Click(object sender, EventArgs e)
        {
            send("reset");
            resetCounter = 5;
            timer5.Enabled = true;
        }

        private void timer5_Tick(object sender, EventArgs e)
        {
            if (resetCounter-- == 0) timer5.Enabled = false;
            sendMsg0('c', 5);
        }

        #endregion

        private void timer3_Tick(object sender, EventArgs e)
        {
            // generate random data
            int where = random.Next(floorNumber);
            byte what = (byte)random.Next(8);

            updateCall(where, what);

            /*
            updateFloorCall(where, what);

            where = random.Next(floorNumber);
            what = (random.Next(2) == 0);
            updateDownCall(where, what);

            where = random.Next(floorNumber);
            what = (random.Next(2) == 0);
            updateUpCall(where, what);
             */
        }

        private void timer4_Tick(object sender, EventArgs e)
        {
            pictureBox1.Refresh();

            if (updateColumns || updateRideTable) redrawRideTable();
        }

        #region Floor table tab

        BindingList<FloorEntry> floorList = new BindingList<FloorEntry>();

        private void numericUpDown1_ValueChanged(object sender, EventArgs e)
        {
            updateFloorNumber((int)numericUpDown1.Value);
            updateColumns = true;
        }

        private void dataGridView3_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            updateColumns = true;
        }

        #endregion

        #region Ride table tab

        int rideState = 0;
        int rideStart = -1;
        int rideStop = -1;
        List<RideEntry> rideList = new List<RideEntry>();
        bool updateRideTable = true;
        bool updateColumns = true;
        Dictionary<string, int[]> companyHash;
        string[] sortedNames;

        private void AppendToRides()
        {
            try
            {
                StreamWriter sw = File.AppendText("rides.csv");
                int i = rideList.Count - 1;
                string s = Utilities.JoinCSV(new List<string>() 
                { 
                    rideList[i].t.ToString(),
                    rideList[i].from.ToString(),
                    rideList[i].to.ToString()
                });
                sw.WriteLine(s);
                sw.Close();
            }
            catch
            {

            }
        }

        private void redrawRideTable()
        {
            // find out all payer names
            companyHash = new Dictionary<string, int[]>();

            for (int i = 0; i < floorList.Count; i++)
            {
                companyHash[floorList[i].Payer] = new int[33];
            }

            if (updateColumns)
            {
                updateColumns = false;

                // clear contents
                listView1.Columns.Clear();

                // sort them
                sortedNames = new string[companyHash.Keys.Count];
                companyHash.Keys.CopyTo(sortedNames, 0);

                Array.Sort(sortedNames, new CaseInsensitiveComparer());

                // add them as column titles
                ColumnHeader ch = new ColumnHeader();
                ch.Text = "Hodina";
                if (comboBox2.SelectedIndex == 1) ch.Text = "Deň";
                if (comboBox2.SelectedIndex == 2) ch.Text = "Mesiac";

                listView1.Columns.Add(ch);

                for (int i = 0; i < sortedNames.Length; i++)
                {
                    ch = new ColumnHeader();
                    ch.Text = sortedNames[i];
                    listView1.Columns.Add(ch);
                }
            }

            if (updateRideTable)
            {
                updateRideTable = false;

                listView1.Items.Clear();

                // go over all data
                int total = 0;

                foreach (RideEntry r in rideList)
                {
                    if (r.from >= floorNumber || r.to >= floorNumber) continue;
                    int floor = r.to;
                    if (floor >= 0 && floor < floorList.Count)
                    {
                        string payer = floorList[floorList.Count - floor - 1].Payer;

                        switch (comboBox2.SelectedIndex)
                        {
                            case 0:
                                // hours of day
                                if (r.t.Date == dateTimePicker1.Value.Date)
                                {
                                    int i = r.t.Hour;
                                    companyHash[payer][i]++;
                                    companyHash[payer][32]++;
                                    total++;
                                }
                                break;

                            case 1:
                                // days of month
                                if ((r.t.Month == dateTimePicker1.Value.Month) &&
                                   (r.t.Year == dateTimePicker1.Value.Year))
                                {
                                    int i = r.t.Day;
                                    companyHash[payer][i]++;
                                    companyHash[payer][32]++;
                                    total++;
                                }
                                break;

                            case 2:
                                // months of year
                                if (r.t.Year == dateTimePicker1.Value.Year)
                                {
                                    int i = r.t.Month;
                                    companyHash[payer][i]++;
                                    companyHash[payer][32]++;
                                    total++;
                                }
                                break;

                            default:
                                break;
                        }
                    }
                }

                // show values
                List<string> tmp;

                switch (comboBox2.SelectedIndex)
                {
                    case 0:
                        // hours of day
                        for (int i = 0; i < 24; i++)
                        {
                            tmp = new List<string>();
                            tmp.Add(i.ToString());

                            foreach (string k in sortedNames)
                            {
                                int j = companyHash[k][i];
                                tmp.Add(j == 0 ? "" : j.ToString());
                            }

                            listView1.Items.Add(new ListViewItem(tmp.ToArray()));
                        }
                        break;

                    case 1:
                        // days of month
                        for (int i = 1; i <= 31; i++)
                        {
                            tmp = new List<string>();
                            tmp.Add(i.ToString());

                            foreach (string k in sortedNames)
                            {
                                int j = companyHash[k][i];
                                tmp.Add(j == 0 ? "" : j.ToString());
                            }

                            listView1.Items.Add(new ListViewItem(tmp.ToArray()));
                        }
                        break;

                    case 2:
                        // months of year
                        DateTimeFormatInfo dtfi = new DateTimeFormatInfo();

                        for (int i = 1; i <= 12; i++)
                        {
                            tmp = new List<string>();
                            tmp.Add(dtfi.GetMonthName(i).ToString());

                            foreach (string k in sortedNames)
                            {
                                int j = companyHash[k][i];
                                tmp.Add(j == 0 ? "" : j.ToString());
                            }

                            listView1.Items.Add(new ListViewItem(tmp.ToArray()));
                        }
                        break;

                    default:
                        break;
                }

                // totals
                tmp = new List<string>();
                tmp.Add("Spolu");

                foreach (string k in sortedNames)
                {
                    int j = companyHash[k][32];
                    tmp.Add(j == 0 ? "" : j.ToString());
                }

                listView1.Items.Add(new ListViewItem(tmp.ToArray()));

                // percentages
                if (total > 0)
                {
                    tmp = new List<string>();
                    tmp.Add("Percentá");
                    foreach (string k in sortedNames)
                    {
                        float f = 100 * companyHash[k][32] / total;
                        tmp.Add(f == 0 ? "" : String.Format("{0:0.00}%", f));
                    }

                    listView1.Items.Add(new ListViewItem(tmp.ToArray()));
                }
            }
        }

        private void button7_Click(object sender, EventArgs e)
        {
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
            {
                // store floor info
                try
                {
                    TextWriter tw = new StreamWriter(saveFileDialog1.FileName);

                    List<string> tmp = new List<string>();

                    for (int i = 0; i < listView1.Columns.Count; i++)
                    {
                        tmp.Add(listView1.Columns[i].Text);
                    }

                    tw.WriteLine(Utilities.JoinCSV(tmp));

                    for (int i = 0; i < listView1.Items.Count; i++)
                    {
                        tmp = new List<string>();

                        for (int j = 0; j < listView1.Items[i].SubItems.Count; j++)
                        {
                            tmp.Add(listView1.Items[i].SubItems[j].Text);
                        }

                        tw.WriteLine(Utilities.JoinCSV(tmp));
                    }

                    tw.Close();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Chyba pri zápise do súboru: " + ex.ToString(), "Chyba", MessageBoxButtons.OK);
                }
            }
        }

        private void comboBox2_SelectedIndexChanged(object sender, EventArgs e)
        {
            updateRideTable = true;
        }

        private void dateTimePicker1_ValueChanged(object sender, EventArgs e)
        {
            updateRideTable = true;
        }

        #endregion

    }
}
