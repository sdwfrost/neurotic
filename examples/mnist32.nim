import sequtils
import neurotic, linalg

proc adjustTest(x: (DMatrix64, int)): (DVector32, int) =
  let (m, i) = x
  (m.asVector.to32, i)

proc adjustTrain(x: (DMatrix64, int)): TrainingData32 =
  let (m, label) = x
  (input: m.asVector.to32, output: oneHot(label, 10).to32)


proc main() =
  let
    l1 = dense32(784, 50)
    l2 = dense32(50, 10)
    cost = QuadraticCost()
  var
    m1 = l1.withMemory
    # m2 = sigmoidModule()
    m2 = reluModule32()
    m3 = l2.withMemory
    m4 = sequential(@[m1, m2, m3])

  let data = mnistTrainData().map(adjustTrain)
  for _ in 1 .. 10:
    # sgd(m4, cost, data)
    miniBatchSgd(m4, cost, data)

  let testData = mnistTestData().map(adjustTest)
  let rightAnswers = m4.evaluate(testData)
  let perc = rightAnswers.float * 100.0 / testData.len.float
  echo "Right answers: ", rightAnswers, " out of ", testData.len
  echo "Perc: ", perc, "%"

when isMainModule:
  main()