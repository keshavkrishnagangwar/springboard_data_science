import matplotlib.pyplot as plt

from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_curve
from sklearn.metrics import roc_auc_score
from sklearn.metrics import average_precision_score
from sklearn.metrics import precision_recall_curve

class Model():

    def __init__(self, classifier, data):
        self.classifier = classifier
        self.data = data

    def model_eval(self, cv=False):
        """This method is used to evaluate model performance. It takes a fitted classification model and
        generates an accuracy score and plots an ROC curve."""

        # extract data
        X_train, X_test, y_train, y_test = self.data

        # calculate predicted probabilities
        y_pred_prob = self.fitted_model.predict_proba(X_test)[:,1]

        # Generate ROC curve values: fpr, tpr, thresholds
        fpr, tpr, thresholds = roc_curve(y_test, y_pred_prob)
        
        # generate precision-recall values
        precision, recall, pr_thresholds = precision_recall_curve(y_test, self.fitted_model.predict(X_test))
        # calculate average precision
        average_precision = average_precision_score(y_test, self.fitted_model.predict(X_test))
        
        # figure settings
        f, (ax1, ax2) = plt.subplots(ncols=2, figsize=(15, 5))

        # plot ROC curve
        ax1.plot([0, 1], [0, 1], 'k--')
        ax1.plot(fpr, tpr)
        ax1.set_xlabel('False Positive Rate')
        ax1.set_ylabel('True Positive Rate')
        ax1.set_title('ROC Curve')
        
        # plot precision-recall curve
        ax2.step(precision, recall, where='post')
        ax2.set_xlabel('Recall')
        ax2.set_ylabel('Precision')
        ax2.set_title('Precion-Recall Curve')
        plt.show()
        
        

        # display results
        print(f'Accuracy on the training data is {round(accuracy_score(y_train, self.fitted_model.predict(X_train)), 3)}.')

        # display model accuracy
        print(f'Accuracy on the test data is {round(accuracy_score(y_test, self.fitted_model.predict(X_test)), 3)}.')

        # display AUC score
        print(f'The model AUC for ROC curve of the test data is {round(roc_auc_score(y_test, y_pred_prob), 3)}')
        
        # display average precision
        print(f'Average precision is {round(average_precision, 3)}.')

        if cv:
            print(f'The best parameters are {self.fitted_model.best_params_}.')


    def model_performance(self, cv=False):
        """This method fits and evaluates a model. Input parameter is classifier type.
        Cv indicates whether evaluating cross validation performance."""

        # extract data
        X_train, X_test, y_train, y_test = self.data
        # initiate classifier
        clf = self.classifier
        # fit model
        self.fitted_model = clf.fit(X_train, y_train)
        # evaluate model
        self.model_eval(cv=cv)
        # return fitted model
        return clf