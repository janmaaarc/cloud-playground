# Project 6 – Lambda & API Gateway

## Objectives
- Create AWS Lambda functions for serverless computing
- Trigger Lambda using AWS API Gateway
- Test API endpoints
- Document setup, commands, and lessons learned
- Include screenshots

---

## Steps

### 1. Create Lambda Function
- Navigate to **Lambda** in AWS Console.
- Click **Create Function** → Author from scratch.
- Provide function name (e.g., `Project6-HelloWorld`).
- Choose runtime (e.g., Python 3.11 or Node.js 20.x).
- Create or assign an execution role with required permissions.

### 2. Add Function Code
- Write basic code to handle requests:
```python
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }
```
- Save and test function using the Lambda console.

### 3. Create API Gateway

- Navigate to API Gateway → Create API → HTTP API.
- Add integration → select Lambda function created.
- Deploy API to a stage (e.g., dev).

### 4. Test API

- Copy API endpoint URL.
- Send GET request using browser or curl:
```bash
curl https://your-api-endpoint.amazonaws.com/dev
```
- Verify Lambda function executes and returns response. 

---

## Notes / Lessons Learned

- Lambda enables serverless execution without managing servers.
- API Gateway allows external clients to call Lambda functions.
- Proper IAM role assignment is crucial for Lambda execution.
- Testing endpoints ensures integration between Lambda and API Gateway.
- Documenting code and API steps helps with future serverless projects.

---

## Screenshots

### Lambda Dashboard
![Lambda Dashboard](screenshots/lambda-dashboard.png)

### Create Lambda Function
![Create Lambda Function](screenshots/create-lambda-function.png)

### API Gateway Test
![API Gateway Test](screenshots/api-gateway-test.png)
