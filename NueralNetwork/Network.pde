class Network {
  Matrix weights_IH;
  Matrix[] weights_HH;
  Matrix weights_HO;
  Matrix[] bias_H;
  Matrix bias_O;
  int numInputs, numOutputs;
  int[] numHiddens;

  Network(int ni, int nh, int no) {
    numInputs=ni;
    numHiddens=new int[1];
    numHiddens[0]=nh;
    numOutputs=no;
    weights_IH=new Matrix(numHiddens[0], numInputs);
    weights_HH=null;
    weights_HO=new Matrix(numOutputs, numHiddens[0]);
    bias_H=new Matrix[1];
    bias_H[0]=new Matrix(numHiddens[0], 1);
    bias_O=new Matrix(numOutputs, 1);
    weights_IH.randomize();
    weights_HO.randomize();
    bias_H[0].randomize();
    bias_O.randomize();
  }

  Network(int ni, int nh, int no, Matrix wih, Matrix who, Matrix bh, Matrix bo) {
    numInputs=ni;
    numHiddens=new int[1];
    numHiddens[0]=nh;
    numOutputs=no;
    weights_IH=wih;
    weights_HH=null;
    weights_HO=who;
    bias_H=new Matrix[1];
    bias_H[0]=bh;
    bias_O=bo;
  }

  Network(int ni, int[] nh, int no) {
    numInputs=ni;
    int len=nh.length;
    numHiddens=new int[len];
    for (int i=0; i<len; ++i) numHiddens[i]=nh[i];
    numOutputs=no;
    weights_IH=new Matrix(numHiddens[0], numInputs);
    if (len==1) weights_HH=null;
    else {
      weights_HH=new Matrix[len-1];
      for (int i=0; i<len-1; ++i) {
        weights_HH[i]=new Matrix(numHiddens[i+1], numHiddens[i]);
      }
    }
    weights_HO=new Matrix(numOutputs, numHiddens[len-1]);
    bias_H=new Matrix[len];
    for (int i=0; i<len; ++i) {
      bias_H[i]=new Matrix(numHiddens[i], 1);
    }
    bias_O=new Matrix(numOutputs, 1);
    weights_IH.randomize();
    if (weights_HH!=null) {
      for (int i=0; i<len-1; ++i) {
        weights_HH[i].randomize();
      }
    }
    weights_HO.randomize();
    for (int i=0; i<len; ++i) {
      bias_H[i].randomize();
    }
    bias_O.randomize();
  }

  Network(int ni, int[] nh, int no, Matrix wih, Matrix[] whh, Matrix who, Matrix[] bh, Matrix bo) {
    int len=nh.length;
    numInputs=ni;
    numHiddens=new int[len];
    for (int i=0; i<len; ++i) {
      numHiddens[i]=nh[i];
    }
    numOutputs=no;
    weights_IH=wih;
    if (whh==null) weights_HH=null;
    else {
      weights_HH=new Matrix[len-1];
      for (int i=0; i<len-1; ++i) {
        weights_HH[i]=whh[i];
      }
    }
    weights_HO=who;
    bias_H=new Matrix[len];
    for (int i=0; i<len; ++i) {
      bias_H[i]=bh[i];
    }
    bias_O=bo;
  }

  JSONObject getJSON() {
    JSONObject json=new JSONObject();
    json.setInt("numInputs", numInputs);
    json.setInt("numOutputs", numOutputs);
    JSONObject wih=weights_IH.getJSON();
    JSONObject who=weights_HO.getJSON();
    int len=numHiddens.length;
    if (weights_HH!=null) {
      JSONArray whh=new JSONArray();
      for (int i=0; i<len-1; ++i) {
        JSONObject whhjson=weights_HH[i].getJSON();
        whh.setJSONObject(i, whhjson);
      }
      json.setJSONArray("weights_HH", whh);
    }
    JSONArray hiddenLayers=new JSONArray();
    for (int i=0; i<len; ++i) {
      JSONObject hljson=new JSONObject();
      hljson.setInt("numHiddens", numHiddens[i]);
      JSONObject bh=bias_H[i].getJSON();
      hljson.setJSONObject("bias_H", bh);
      hiddenLayers.setJSONObject(i, hljson);
    }
    JSONObject bo=bias_O.getJSON();
    json.setJSONObject("weights_IH", wih);
    json.setJSONObject("weights_HO", who);
    json.setJSONArray("hiddenLayers", hiddenLayers);
    json.setJSONObject("bias_O", bo);
    return json;
  }

  float[] predict(float[] inputs) {
    Matrix input=Matrix.fromArray(inputs);
    float[] hidden_array=Matrix.add(Matrix.mul(weights_IH, input), bias_H[0]).toArray();
    Matrix hidden=Matrix.fromArray(activationFunctionIH(hidden_array));
    if (weights_HH!=null) {
      int len=numHiddens.length;
      for (int i=0; i<len-1; ++i) {
        hidden_array=Matrix.add(Matrix.mul(weights_HH[i], hidden), bias_H[i+1]).toArray();
        hidden=Matrix.fromArray(activationFunctionIH(hidden_array));
      }
    }
    float[] output_array=Matrix.add(Matrix.mul(weights_HO, hidden), bias_O).toArray();
    return activationFunctionHO(output_array);
  }

  float[] activationFunctionIH(float[] v) {
    int len=v.length;
    float ans[]=new float[len];
    for (int i=0; i<len; ++i) {
      ans[i]=1/(1+exp(-1*v[i]));
    }
    return ans;
  }

  float[] activationFunctionHO(float[] v) {
    int len=v.length;
    float ans[]=new float[len];
    float sum=0;
    for (int i=0; i<len; ++i) {
      sum+=Math.exp(v[i]);
    }
    for (int i=0; i<len; ++i) {
      ans[i]=(float)(Math.exp(v[i])/sum);
    }
    return ans;
  }

  Network mutate(float mr) {
    int len=numHiddens.length;
    Matrix new_weights_IH=weights_IH.mutate(mr);
    Matrix[] new_weights_HH;
    if (weights_HH!=null) {
      new_weights_HH=new Matrix[len-1];
      for (int i=0; i<len-1; ++i) {
        new_weights_HH[i]=weights_HH[i].mutate(mr);
      }
    } else new_weights_HH=null;
    Matrix new_weights_HO=weights_HO.mutate(mr);
    Matrix new_bias_H[]=new Matrix[len];
    for (int i=0; i<len; ++i) {
      new_bias_H[i]=bias_H[i].mutate(mr);
    }
    Matrix new_bias_O=bias_O.mutate(mr);
    return new Network(numInputs, numHiddens, numOutputs, new_weights_IH, new_weights_HH, new_weights_HO, new_bias_H, new_bias_O);
  }
}
