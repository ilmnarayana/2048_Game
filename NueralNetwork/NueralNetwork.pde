import java.util.Scanner;

void setup() {
  size(0, 0);
  int[] hl={10, 8, 6, 5};
  Network nn=new Network(10, 20, 5);
  nn.mutate(0.1);
  float[] inputs={1, 5, 3, 4, 6, 3, 9, 7, 3, 2};
  saveJSONObject(nn.getJSON(), "SomeS.json");
  Network nn2=networkFromJSON(loadJSONObject("SomeS.json"));
  float[] output=nn2.predict(inputs);
  for (int i=0; i<output.length; ++i) {
    print(output[i]+" ");
  }
}

Matrix matrixFromJSON(JSONObject json) {
  int rows=json.getInt("rows");
  int cols=json.getInt("cols");
  String s=json.getString("data");
  Scanner scan=new Scanner(s);
  float[][] data=new float[rows][cols];
  for (int i=0; i<rows; ++i) {
    for (int j=0; j<cols; ++j) {
      data[i][j]=scan.nextFloat();
    }
  }
  scan.close();
  return new Matrix(rows, cols, data);
}

Network networkFromJSON(JSONObject json) {
  int numInputs=json.getInt("numInputs");
  int numOutputs=json.getInt("numOutputs");
  Matrix wih=matrixFromJSON(json.getJSONObject("weights_IH"));
  Matrix who=matrixFromJSON(json.getJSONObject("weights_HO"));
  Matrix bo=matrixFromJSON(json.getJSONObject("bias_O"));
  JSONArray hiddenLayers=json.getJSONArray("hiddenLayers");
  int len=hiddenLayers.size();
  int[] numHiddens=new int[len];
  Matrix[] bh=new Matrix[len];
  for (int i=0; i<len; ++i) {
    JSONObject hljson=hiddenLayers.getJSONObject(i);
    numHiddens[i]=hljson.getInt("numHiddens");
    bh[i]=matrixFromJSON(hljson.getJSONObject("bias_H"));
  }
  Matrix[] whh;
  if (len==1) whh=null;
  else {
    whh=new Matrix[len-1];
    JSONArray whharr=json.getJSONArray("weights_HH");
    for (int i=0; i<len-1; ++i) {
      whh[i]=matrixFromJSON(whharr.getJSONObject(i));
    }
  }
  return new Network(numInputs, numHiddens, numOutputs, wih, whh, who, bh, bo);
}
