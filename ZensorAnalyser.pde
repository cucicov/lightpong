class ZensorAnalyser {
  
  private int[] sensorValues;
  private int ignoreSensor;
  private float thresholdForSensorActivePercent = 0;
  private int averageSensors = 0;
  private int activeSensor;
  
  public ZensorAnalyser(int[] sensorValues, float thresholdForSensorActivePercent, int ignoreSensor) {
    this.sensorValues = sensorValues;
    this.thresholdForSensorActivePercent = thresholdForSensorActivePercent;
    this.ignoreSensor = ignoreSensor;
    
    init();
  }
  
  
  
  private void init() {
    this.averageSensors = getSensorAverageValues();
    decideActiveSensor();
  }
  
  public float getRelativeSensorPosition() {
    int differenceToLeftNeigh = getDifferenceToLeftNeighbour(activeSensor);
    int differenceToRightNeigh = getDifferenceToRightNeighbour(activeSensor);
    int totalRange = differenceToLeftNeigh + differenceToRightNeigh;
    
    return (float)differenceToLeftNeigh / (float)totalRange;
  }
  
  public int getDifferenceToLeftNeighbour(int activeSensorId) {
    if (activeSensorId == 0) {
      return abs(sensorValues[activeSensorId] - this.averageSensors);
    }
    return abs(sensorValues[activeSensorId] - sensorValues[activeSensorId - 1]);
  }
  
  public int getDifferenceToRightNeighbour(int activeSensorId) {
    if (activeSensorId == sensorValues.length-1) {
      return abs(sensorValues[activeSensorId] - this.averageSensors);
    }
    return abs(sensorValues[activeSensorId] - sensorValues[activeSensorId + 1]);
  }
  
  public void decideActiveSensor() {
    int activeSensorId = 0;
    boolean newValueFound = false;
    
    for (int i = 0; i < sensorValues.length; i++) {
      int currentSensorValue = sensorValues[i];
      int currentSensorLeader = sensorValues[activeSensorId];
      int roughtDifference = abs(currentSensorValue - this.averageSensors);
      int percentFromAverageSensorValues = (int)(this.thresholdForSensorActivePercent * this.averageSensors);
      
      // if this sensor value is greater than "thresholdForSensorActivePercent"% from average -> check if new value higher than current highest value.
      if (roughtDifference > percentFromAverageSensorValues && currentSensorValue >= currentSensorLeader && this.ignoreSensor != i) {
        activeSensorId = i;
        newValueFound = true;
      }
    }
    
    this.activeSensor = newValueFound ? activeSensorId : -1; // if no new value is found, return invalid sensor id.
    
  }
  
  private int getSensorAverageValues() {
    int avg = 0;
    for (int i=0; i < this.sensorValues.length; i++) {
      avg += this.sensorValues[i];
    }
    return avg / this.sensorValues.length;
  }
  
  public int getActiveSensor() {
    return this.activeSensor;
  }

}