# polygon-CTFs
Polygon Labs ethDenver CTFs

## How to play
1. Clone the repository
2. Set a valid RPC URL in the .env file as specified in the .env.example file
3. Install Docker
4. build the Docker image with `docker build -t polygon-ctfs .`
5. run the Docker container with `docker run -it --rm -v "/${PWD}:/polygon-ctfs" polygon-ctfs bash`
6. Code your solution in the `Attacker.sol` file (inside each challenge's folder in the test folder)
7. Run the challenge with `forge test --mt ChallengeNameChallenge challenge-name`. If the test is executed successfully, you've passed!
