static class Matrix {
  float data[][];
  int rows, cols;

  Matrix(int r, int c) {
    data=new float[r][c];
    rows=r;
    cols=c;
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        data[i][j]=0;
      }
    }
  }

  Matrix(int r, int c, float[][] d) {
    data=d;
    rows=r;
    cols=c;
  }

  void display() {
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        print(data[i][j]);
        print(' ');
      }
      println();
    }
    println();
  }

  JSONObject getJSON() {
    JSONObject json=new JSONObject();
    json.setInt("rows", rows);
    json.setInt("cols", cols);
    String s="";
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        s+=data[i][j];
        s+=" ";
      }
    }
    json.setString("data", s);
    return json;
  }

  float gaussianRandom(float sd) {
    float r1, r2, w;
    do {
      r1=(float)((Math.random()*2)-1);
      r2=(float)((Math.random()*2)-1);
      w=(r1*r1)+(r2*r2);
    } while (w>=1);
    w=sqrt((-2*log(w))/w);
    return r1*w*sd;
  }

  Matrix mutate(float mr) {
    float[][] new_data=new float[rows][cols];
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        float r=(float)Math.random();
        if (r<mr/5) new_data[i][j]=(float)((Math.random()*2)-1);
        else if (r<(3*mr)/5) new_data[i][j]=data[i][j]+gaussianRandom(0.1);
        else new_data[i][j]=data[i][j];
      }
    }
    return new Matrix(rows, cols, new_data);
  }

  void randomize(float x, float y) {
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        data[i][j]=(float)((Math.random()*(y-x))+x);
      }
    }
  }

  void randomize() {
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        data[i][j]=(float)((Math.random()*2)-1);
      }
    }
  }

  void makeInt() {
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        data[i][j]=(int)(data[i][j]);
      }
    }
  }

  void add(Matrix m) {
    if (m.rows!=rows || m.cols!=cols) {
      println("Wrong Matrix dimensions");
      return;
    }
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        data[i][j]+=m.data[i][j];
      }
    }
  }

  void add(float val) {
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        data[i][j]+=val;
      }
    }
  }

  static Matrix add(Matrix m1, Matrix m2) {
    if (m1.rows!=m2.rows || m1.cols!=m2.cols) {
      println("Wrong Matrix dimensions");
      return null;
    }
    Matrix ans=new Matrix(m1.rows, m1.cols);
    for (int i=0; i<m1.rows; ++i) {
      for (int j=0; j<m1.cols; ++j) {
        ans.data[i][j]=m1.data[i][j]+m2.data[i][j];
      }
    }
    return ans;
  }

  static Matrix add(Matrix m, float val) {
    Matrix ans=new Matrix(m.rows, m.cols);
    for (int i=0; i<m.rows; ++i) {
      for (int j=0; j<m.cols; ++j) {
        ans.data[i][j]=m.data[i][j]+val;
      }
    }
    return ans;
  }

  void mul(float val) {
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        data[i][j]*=val;
      }
    }
  }

  void elemMul(float val) {
    mul(val);
  }

  void elemMul(Matrix m) {
    if (m.rows!=rows || m.cols!=cols) {
      println("Wrong Matrix dimensions");
      return;
    }
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        data[i][j]*=m.data[i][j];
      }
    }
  }

  void mul(Matrix m) {
    if (cols!=m.rows) {
      println("Wrong Matrix dimensions");
      return;
    }
    float newData[][]=new float[rows][m.cols];
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<m.cols; ++j) {
        float sum=0;
        for (int k=0; k<cols; ++k) {
          sum+=data[i][k]*m.data[k][j];
        }
        newData[i][j]=sum;
      }
    }
    data=newData;
    cols=m.cols;
  }

  static Matrix mul(Matrix m, float val) {
    Matrix ans=new Matrix(m.rows, m.cols);
    for (int i=0; i<m.rows; ++i) {
      for (int j=0; j<m.cols; ++j) {
        ans.data[i][j]=m.data[i][j]*val;
      }
    }
    return ans;
  }

  static Matrix elemMul(Matrix m, float val) {
    return mul(m, val);
  }

  static Matrix elemMul(Matrix m1, Matrix m2) {
    if (m1.rows!=m2.rows || m1.cols!=m2.cols) {
      println("Wrong Matrix dimensions");
      return null;
    }
    Matrix ans=new Matrix(m1.rows, m1.cols);
    for (int i=0; i<m1.rows; ++i) {
      for (int j=0; j<m1.cols; ++j) {
        ans.data[i][j]=m1.data[i][j]*m2.data[i][j];
      }
    }
    return ans;
  }

  static Matrix mul(Matrix m1, Matrix m2) {
    if (m1.cols!=m2.rows) {
      println("Wrong Matrix dimensions");
      return null;
    }
    Matrix ans=new Matrix(m1.rows, m2.cols);
    for (int i=0; i<m1.rows; ++i) {
      for (int j=0; j<m2.cols; ++j) {
        float sum=0;
        for (int k=0; k<m1.cols; ++k) {
          sum+=m1.data[i][k]*m2.data[k][j];
        }
        ans.data[i][j]=sum;
      }
    }
    return ans;
  }

  void transpose() {
    float newData[][]=new float[cols][rows];
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        newData[j][i]=data[i][j];
      }
    }
    data=newData;
    int temp=rows;
    rows=cols;
    cols=temp;
  }

  static Matrix transpose(Matrix m) {
    Matrix ans=new Matrix(m.cols, m.rows);
    for (int i=0; i<m.rows; ++i) {
      for (int j=0; j<m.cols; ++j) {
        ans.data[j][i]=m.data[i][j];
      }
    }
    return ans;
  }

  float[] toArray() {
    float[] ans=new float[rows*cols];
    int ctr=0;
    for (int i=0; i<rows; ++i) {
      for (int j=0; j<cols; ++j) {
        ans[ctr++]=data[i][j];
      }
    }
    return ans;
  }

  static float[] toArray(Matrix m) {
    float[] ans=new float[m.rows*m.cols];
    int ctr=0;
    for (int i=0; i<m.rows; ++i) {
      for (int j=0; j<m.cols; ++j) {
        ans[ctr++]=m.data[i][j];
      }
    }
    return ans;
  }

  static Matrix fromArray(float[] v) {
    int len=v.length;
    Matrix ans=new Matrix(len, 1);
    for (int i=0; i<len; ++i) {
      ans.data[i][0]=v[i];
    }
    return ans;
  }
}
