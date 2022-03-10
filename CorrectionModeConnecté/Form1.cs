using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;
namespace CorrectionModeConnecté
{
    public partial class Form1 : Form
    {
    
        string cs = @"data source=.\sqlexpress;initial catalog=employees;user id=sa;password=P@ssw0rd";
         
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {    SqlConnection cn;
              cn = new SqlConnection(cs);
            cn.Open();

            SqlCommand com = new SqlCommand("select num_serv, nom_serv from service",cn);
            SqlDataReader dr = com.ExecuteReader();
            DataTable dt = new DataTable();
        dt.Load(dr);
            cboServices.DisplayMember = "nom_serv";
            cboServices.ValueMember = "num_serv";
            cboServices.DataSource = dt;
            dr.Close();
            dr = null;
            com = null;
            cn.Close();
            cn = null;

        }

        private void cboServices_SelectedIndexChanged(object sender, EventArgs e)
        {
           btnRecherche.PerformClick(); 
        }
        

        private void btnRecherche_Click(object sender, EventArgs e)
        {
            if (cboServices.SelectedIndex != -1)
            {
                SqlConnection cn;
                cn = new SqlConnection(cs);
                cn.Open();

                SqlCommand com = new SqlCommand("select matricule, nom, prenom from employe where (nom like @rech or prenom like @rech   ) and num_serv = " + cboServices.SelectedValue, cn);
                com.Parameters.AddWithValue("@rech","%" + txtRecherche.Text + "%");


                SqlDataReader dr = com.ExecuteReader();
                DataTable dt = new DataTable();
                dt.Load(dr);
                lstEmployees.DisplayMember = "nom";
                lstEmployees.ValueMember = "matricule";
                initTextes();
                lstEmployees.DataSource = dt;
                dr.Close();
                dr = null;
                com = null;
                cn.Close();
                cn = null;
            }
            else
            {
                lstEmployees.Items.Clear();
                initTextes();
            }

        }

        private void txtRecherche_TextChanged(object sender, EventArgs e)
        {
          
        }

        private void txtRecherche_KeyUp(object sender, KeyEventArgs e)
        {
            if(e.KeyCode == Keys.Enter)
            {
                btnRecherche.PerformClick();
            }
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void lstEmployees_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (lstEmployees.SelectedIndex != -1)
            {
                SqlConnection cn;
                cn = new SqlConnection(cs);
                cn.Open();

                SqlCommand com = new SqlCommand("select * from employe where matricule = " + lstEmployees.SelectedValue, cn);
                SqlDataReader dr = com.ExecuteReader();
                DataTable dt = new DataTable();
                dt.Load(dr);
                initTextes();

                txtMatricule.DataBindings.Add("Text", dt, "matricule");
                txtNom.DataBindings.Add("Text", dt, "nom");
                txtPrenom.DataBindings.Add("Text", dt, "prenom");
                txtDN.DataBindings.Add("Text", dt, "dateNaissance");
                txtAdresse.DataBindings.Add("Text", dt, "adresse");
                txtSalaire.DataBindings.Add("Text", dt, "salaire");
                txtGrade.DataBindings.Add("Text", dt, "grade");






                dr.Close();
                dr = null;
                com = null;
                cn.Close();
                cn = null;
            }
            else
            {

                initTextes();
            }
        }

        public void initTextes()
        {
            txtMatricule.DataBindings.Clear();
            txtNom.DataBindings.Clear();
            txtPrenom.DataBindings.Clear();
            txtDN.DataBindings.Clear();
            txtAdresse.DataBindings.Clear();
            txtSalaire.DataBindings.Clear();
            txtGrade.DataBindings.Clear();

            txtMatricule.Clear();
            txtNom.Clear();
            txtPrenom.Clear();
            txtDN.Clear();
            txtAdresse.Clear();
            txtSalaire.Clear();
            txtGrade.Clear();

        }

        private void btnSuivant_Click(object sender, EventArgs e)
        {
            if(lstEmployees.SelectedIndex < lstEmployees.Items.Count-1)
            {
                lstEmployees.SelectedIndex++;
            }
        }

        private void btnPrecedent_Click(object sender, EventArgs e)
        {
            if (lstEmployees.SelectedIndex > 0)
            {
                lstEmployees.SelectedIndex--;
            }
        }

        private void btnDernier_Click(object sender, EventArgs e)
        {
            lstEmployees.SelectedIndex = lstEmployees.Items.Count - 1;
        }

        private void btnPremier_Click(object sender, EventArgs e)
        {
            if (lstEmployees.Items.Count > 0)
                lstEmployees.SelectedIndex = 0;
          
        }

        private void btnAjouter_Click(object sender, EventArgs e)
        {
            initTextes();   

        }

        private void btnValider_Click(object sender, EventArgs e)
        {

            SqlConnection cn;
            cn = new SqlConnection(cs);
            cn.Open();

            SqlCommand com = new SqlCommand("insert into employe values ( @nom, @prenom, @dn,@adresse, @salaire,@grade,@num_serv )", cn);
         
            com.Parameters.AddWithValue("@nom", txtNom.Text);
            com.Parameters.AddWithValue("@prenom", txtPrenom.Text);
            com.Parameters.AddWithValue("@dn", txtDN.Text);
            com.Parameters.AddWithValue("@adresse", txtAdresse.Text);
            com.Parameters.AddWithValue("@salaire", txtSalaire.Text);
            com.Parameters.AddWithValue("@grade", txtGrade.Text);
            com.Parameters.AddWithValue("@num_serv", cboServices.SelectedValue);


            com.ExecuteNonQuery();

        btnRecherche.PerformClick();    




           
            com = null;
            cn.Close();
            cn = null;
        }
    }
}
