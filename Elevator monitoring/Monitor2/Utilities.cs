using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace Monitor
{
    class Utilities
    {
        // even number of double quotes after comma -> split on it
        private static Regex reCommaCsv = new Regex(",(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))");
        
        // quoted string
        private static Regex reFix1 = new Regex("^\"(.*)\"$");
        
        // double double quote
        private static Regex reFix2 = new Regex("\"\"");

        public static string[] SplitCSV(string line)
        {
            string[] s = reCommaCsv.Split(line);

            for (int i = 0; i < s.Length; i++ )
            {
                s[i] = s[i].Trim();
                Match m = reFix1.Match(s[i]);
                if (m.Success)
                {
                    s[i] = m.Groups[1].Value;
                }
                s[i] = reFix2.Replace(s[i], "\"");
            }
            return s;
        }

        public static string JoinCSV(List<string> s)
        {
            for (int i = 0; i < s.Count; i++)
            {
                s[i] = s[i].Replace("\"", "\"\"");

                if (s[i].Contains(","))
                {
                    s[i] = "\"" + s[i] + "\"";
                }
            }

            return String.Join(",", s.ToArray());
        }
    }
}
